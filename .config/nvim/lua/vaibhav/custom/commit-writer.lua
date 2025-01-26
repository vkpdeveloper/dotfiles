-- [[
-- commit writer
-- @params model_name string -> all supported models can be found at https://ollama.com/search
-- ]]

PROMPT = [[
    You are a git commit writer, your task is to analyse the given code changes and generate a commit message in the given format based on the given diffs.
    diff via:
    -- + -> lines added
    -- - -> lines removed
    -- ~ -> lines modified

    -- DIFF EXAMPLE --
    file_name:
    + line_number: line_content

    -- FORMAT --
    <type>(<scope>): <subject>

    <body>
    -- FORMAT END --

    -- RULES --
    - make sure to follow the format and only respond in the given format and nothing else should be there in the resoonse.
    - type, scope and subject are mandatory
    - make sure the subject is less than 50 characters
    - body is under 350 characters
    - make sure to not add any other information that is not part of the commit message like author name and email or issue number or anything like that
    - make sure the commit body is formated like a markdown list-item or a bullet point and covers everything that has changed based on the diff
    -- RULES END --

    -- INPUT --

    #diffs#
    -- INPUT END --
]]

CLAUDE_API_ENDPOINT = "https://api.anthropic.com/v1/messages"
CLAUDE_API_KEY = vim.env.CLAUDE_API_KEY

local function handle_stream_chunk(data, callback)
	vim.schedule(function()
		local json_data = data:match("^data: (.+)")
		if json_data then
			local success, decoded = pcall(vim.json.decode, json_data)
			if success then
				if decoded.type == "content_block_delta" then
					callback(decoded.delta.text)
				end
			end
		end
	end)
end

local function commit_writer(model_name)
	local current_buffer_name = vim.api.nvim_buf_get_name(0)
	if current_buffer_name:find("COMMIT_EDITMSG") == nil then
		vim.notify("Please open the COMMIT_EDITMSG buffer to use the commit writer.")
		return
	end

	local diffs = {}

	local branch_name = vim.fn.system("git symbolic-ref --short HEAD"):gsub("\n$", "")

	local git_repo_path = vim.fn.system("git rev-parse --show-prefix"):gsub("\n$", "")
	local modified_file_paths = vim.fn.systemlist("git diff --name-only " .. branch_name)
	local untracked_file_paths = vim.fn.systemlist("git ls-files --others --exclude-standard")

	for _, file_path in ipairs(modified_file_paths) do
		local modified_path = file_path:gsub(git_repo_path, "")
		local diff = vim.fn.system("git diff --staged " .. modified_path):gsub("\n$", "")
		diffs[file_path] = diff
	end

	for _, file_path in ipairs(untracked_file_paths) do
		local modified_path = file_path:gsub(git_repo_path, "")
		local diff = vim.fn.system('cat "' .. modified_path .. '"'):gsub("\n$", "")
		diffs[file_path] = diff
	end

	local prompt = PROMPT:gsub("#branch_name#", branch_name)
	local diff_str = ""

	for file_path, diff in pairs(diffs) do
		diff_str = diff_str .. "# " .. file_path .. "\n" .. diff .. "\n\n"
	end

	prompt = prompt:gsub("#diffs#", diff_str)

	-- copy the prompt to the clipboard
	vim.fn.setreg("+", prompt)

	local commit_message = ""
	local current_line = ""
	local line_number = nil

	local function update_message(chunk)
		commit_message = commit_message .. chunk

		vim.schedule(function()
			-- Initialize line number if not set
			if not line_number then
				local pos = vim.api.nvim_win_get_cursor(0)
				line_number = pos[1] - 1 -- Convert to 0-based index
			end

			-- Append chunk to current line
			current_line = current_line .. chunk

			-- Split the current line by newlines
			local lines = vim.split(current_line, "\n", { plain = true })

			-- If we have multiple lines, write all complete lines
			if #lines > 1 then
				for i = 1, #lines - 1 do
					vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { lines[i] })
					line_number = line_number + 1
				end
				-- Keep the last incomplete line in current_line
				current_line = lines[#lines]
			end

			-- If the chunk ends with a newline, write the current line and reset it
			if chunk:match("\n$") then
				vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { current_line })
				line_number = line_number + 1
				current_line = ""
			end

			-- Always ensure the current incomplete line is visible
			vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { current_line })
		end)
	end

	vim.schedule(function()
		vim.notify("Generating commit message...")
		-- First, create a proper table structure
		local request_body = {
			model = model_name,
			max_tokens = 300,
			system = prompt,
			stream = true,
			messages = {
				{
					role = "user",
					content = "Generate the commit",
				},
			},
		}

		local post_data = vim.fn.json_encode(request_body)

		local curl = require("plenary.curl")
		local headers = {
			["Content-Type"] = "application/json",
			["anthropic-version"] = "2023-06-01",
			["x-api-key"] = CLAUDE_API_KEY,
		}

		-- Make the curl request with proper escaping

		local response = curl.post(CLAUDE_API_ENDPOINT, {
			body = post_data,
			headers = headers,
			stream = function(err, chunk, _)
				handle_stream_chunk(chunk, update_message)
			end,
		})
	end)
end

vim.keymap.set("n", "<leader>gw", function()
	local model_name = "claude-3-5-sonnet-20241022"
	commit_writer(model_name)
end, { silent = true })

vim.keymap.set("n", "<leader>so", "<cmd>so %<cr>", { silent = true })
