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
			if success and decoded.type == "content_block_delta" then
				callback(decoded.delta.text)
			end
		end
	end)
end

local function commit_writer(model_name)
	if not vim.api.nvim_buf_get_name(0):find("COMMIT_EDITMSG") then
		vim.notify("Please open the COMMIT_EDITMSG buffer to use the commit writer.")
		return
	end

	local diffs = {}
	local branch_name = vim.fn.system("git symbolic-ref --short HEAD"):gsub("\n$", "")
	local git_repo_path = vim.fn.system("git rev-parse --show-prefix"):gsub("\n$", "")

	-- Get modified and untracked files
	local modified_files = vim.fn.systemlist("git diff --cached --name-only")
	local untracked_files = vim.fn.systemlist("git ls-files --others --exclude-standard")

	-- Handle modified files
	for _, file in ipairs(modified_files) do
		local diff = vim.fn.system("git diff --cached " .. vim.fn.shellescape(file))
		if diff ~= "" then
			diffs[file] = diff
		end
	end

	-- Handle untracked files
	for _, file in ipairs(untracked_files) do
		local file_content = vim.fn.system("cat " .. vim.fn.shellescape(file))
		if file_content ~= "" then
			diffs[file] = file_content
		end
	end

	-- Prepare request
	local request_body = {
		model = model_name,
		messages = { {
			role = "user",
			content = "Generate the commit",
		} },
		system = PROMPT:gsub(
			"#diffs#",
			table.concat(
				vim.tbl_map(function(file)
					return "# " .. file .. "\n" .. diffs[file] .. "\n"
				end, vim.tbl_keys(diffs)),
				"\n"
			)
		),
	}

	-- Set up streaming
	local line_number = nil
	local current_line = ""
	local function update_message(chunk)
		vim.schedule(function()
			if not line_number then
				line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
			end

			current_line = current_line .. chunk
			local lines = vim.split(current_line, "\n", { plain = true })

			if #lines > 1 then
				for i = 1, #lines - 1 do
					vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { lines[i] })
					line_number = line_number + 1
				end
				current_line = lines[#lines]
			end

			if chunk:match("\n$") then
				vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { current_line })
				line_number = line_number + 1
				current_line = ""
			end

			vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, { current_line })
		end)
	end

	-- Make API request
	local curl = require("plenary.curl")
	curl.post(CLAUDE_API_ENDPOINT, {
		body = vim.fn.json_encode(request_body),
		headers = {
			["Content-Type"] = "application/json",
			["Anthropic-Version"] = "2023-06-01",
			["X-Api-Key"] = CLAUDE_API_KEY,
		},
		stream = function(_, chunk)
			handle_stream_chunk(chunk, update_message)
		end,
	})
end

-- Set up keymaps
vim.keymap.set("n", "<leader>gw", function()
	commit_writer("claude-3-5-sonnet-20241022")
end, { silent = true })

vim.keymap.set("n", "<leader>so", "<cmd>so %<cr>", { silent = true })
