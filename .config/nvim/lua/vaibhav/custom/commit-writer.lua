-- [[
-- commit writer
-- @params model_name string -> all supported models can be found at https://ollama.com/search
-- ]]

PROMPT = [[
You are a git commit writer, your task is to analyze the given code changes and generate a clear, concise, and informative commit message based on the provided diffs.

diff via:
-- + -> lines added
-- - -> lines removed
-- ~ -> lines modified

-- FORMAT --
<type>(<scope>): <subject>

<body>
-- FORMAT END --

-- COMMIT TYPES --
feat: A new feature or enhancement
fix: A bug fix
docs: Documentation changes only
style: Changes that do not affect code functionality (formatting, whitespace, etc.)
refactor: Code changes that neither fix a bug nor add a feature
perf: Performance improvements
test: Adding or modifying tests
chore: Changes to the build process, tools, or dependencies
ci: Changes to CI configuration files and scripts
revert: Reverting a previous commit
-- COMMIT TYPES END --

-- RULES --
1. Follow the exact format above - nothing else should be in your response
2. Type, scope, and subject are mandatory
   - Type must be one of the listed commit types
   - Scope should identify the component or area of the codebase
   - Subject must be less than 50 characters and use imperative mood (e.g., "add" not "added")
3. The subject:
   - Should start with a lowercase letter
   - Should not end with a period
   - Must use the imperative mood (e.g., "change" not "changes")
   - Must be less than 50 characters
4. The body:
   - Format as a markdown bullet list (each item starts with "- ")
   - List all significant changes, including the file and line number where appropriate
   - Be specific about what changed and why, not just what files were modified
   - Mention any breaking changes first with "BREAKING CHANGE: " prefix
   - For purely formatting changes (whitespace, indentation), use "style" type and briefly mention
   - For mixed changes (both formatting and functionality), prioritize functional changes
5. Prioritize in this order: breaking changes > feature changes > bug fixes > other changes
6. Don't include commit metadata (author, issue numbers, etc.)
7. Be concise but descriptive - explain the "what" and "why" not just the "how"
8. If changes are trivial or only formatting, still be specific about what formatting was changed
-- RULES END --

-- EXAMPLES --
Example 1 (Feature):
feat(auth): add password reset functionality

- Add ResetPassword component in auth/reset.tsx
- Implement password reset API endpoint in auth/api.ts
- Add email notification service for reset links
- Update user model to track password reset tokens

Example 2 (Bug Fix):
fix(cart): resolve items disappearing after page refresh

- Fix localStorage persistence logic in cart/store.ts
- Add session recovery mechanism on page load
- Implement proper error handling for failed cart operations

Example 3 (Style Only):
style(components): improve button formatting consistency

- Standardize button padding and margins across all components
- Align text positioning within button elements
- Fix indentation in button component files
-- EXAMPLES END --

-- INPUT --
#diffs#
-- INPUT END --
]]

CLAUDE_API_ENDPOINT = "https://api.anthropic.com/v1/messages"
CLAUDE_API_KEY = vim.env.CLAUDE_API_KEY

GEMINI_API_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
GEMINI_API_KEY = vim.env.GEMINI_API_KEY

local function print_error(msg)
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.ERROR)
	end)
end

local function print_info(msg)
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.INFO)
	end)
end

local function handle_stream_chunk(data, callback)
	if data == nil then
		print_info("Generation completed")
		callback("")
		return
	end

	vim.schedule(function()
		local json_data = data:match("^data: (.+)")
		if json_data then
			local success, decoded = pcall(vim.json.decode, json_data)
			if success then
				if decoded.type == "content_block_delta" then
					callback(decoded.delta.text)
				end
			else
				print_error("Failed to decode JSON: " .. decoded)
			end
		end
	end)
end

local function sanitize_diff(diff_str)
<<<<<<< HEAD
	if not diff_str then
		print_error("No diff string provided")
		return ""
	end

	-- List of Lua pattern special characters to escape
	local special_chars = {
		"%",
		"^",
		"$",
		"(",
		")",
		".",
		"[",
		"]",
		"*",
		"+",
		"-",
		"?",
		"#",
	}

	local sanitized = diff_str
	for _, char in ipairs(special_chars) do
		-- Escape each special character with %
		-- We need to use % to escape % itself, hence %%
		if char == "%" then
			sanitized = sanitized:gsub("%%", "%%%%")
		else
			sanitized = sanitized:gsub("%" .. char, "%%" .. char)
		end
	end

	return sanitized
=======
    if not diff_str then
        print_error("No diff string provided")
        return ""
    end
    -- List of Lua pattern special characters to escape
    local special_chars = {
        "%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?", "#"
    }
    local sanitized = diff_str
    for _, char in ipairs(special_chars) do
        -- Escape each special character with %
        -- We need to use % to escape % itself, hence %%
        if char == "%" then
            sanitized = sanitized:gsub("%%", "%%%%")
        else
            sanitized = sanitized:gsub("%" .. char, "%%" .. char)
        end
    end
    return sanitized
>>>>>>> 109acd6 (feat(commit-writer): improve commit message generation)
end

local function check_git_environment()
	-- Check if we're in a git repository
	local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
	if is_git_repo == "" then
		print_error("Not in a git repository")
		return false
	end

	-- Check if CLAUDE_API_KEY is set
	if not CLAUDE_API_KEY or CLAUDE_API_KEY == "" then
		print_error("CLAUDE_API_KEY environment variable is not set")
		return false
	end

	return true
end

local function format_git_output(output)
    if not output then return "" end

    -- Normalize line endings
    local normalized = output:gsub("\r\n", "\n")

    -- Add line breaks to improve readability where missing
    -- Look for import statements without line breaks
    normalized = normalized:gsub("import([^;]+);import", "import%1;\n\nimport")

    -- Add line breaks between JSX elements where needed
    normalized = normalized:gsub(">([ ]*)<", ">\n%1<")

    -- Add line breaks for code blocks (function declarations, etc)
    normalized = normalized:gsub("function ([^{]+){", "function %1{\n")

    return normalized
end

local function sanitize_for_api(text)
    if not text then return "" end

    -- Proper JSON escaping
    local sanitized = text:gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("\n", "\\n")

    return sanitized
end

local function commit_writer(model_name)
	if not check_git_environment() then
		return
	end

	local current_buffer_name = vim.api.nvim_buf_get_name(0)
	if current_buffer_name:find("COMMIT_EDITMSG") == nil then
		print_error("Please open the COMMIT_EDITMSG buffer to use the commit writer")
		return
	end

	local diffs = {}
	local success, branch_name = pcall(vim.fn.system, "git symbolic-ref --short HEAD")
	if not success then
		print_error("Failed to get branch name: " .. branch_name)
		return
	end
	branch_name = branch_name:gsub("\n$", "")

	local success, git_repo_path = pcall(vim.fn.system, "git rev-parse --show-prefix")
	if not success then
		print_error("Failed to get repo path: " .. git_repo_path)
		return
	end
	git_repo_path = git_repo_path:gsub("\n$", "")

	local success, modified_files = pcall(vim.fn.systemlist, "git diff --cached --name-only")
	if not success then
		print_error("Failed to get modified files: " .. vim.inspect(modified_files))
		return
	end

	local success, untracked_files = pcall(vim.fn.systemlist, "git ls-files --others --exclude-standard")
	if not success then
		print_error("Failed to get untracked files: " .. vim.inspect(untracked_files))
		return
	end

	for _, file in ipairs(modified_files) do
		local success, diff = pcall(vim.fn.system, "git diff --cached " .. vim.fn.shellescape(file))
		if not success then
			print_error("Failed to get diff for file " .. file .. ": " .. diff)
		elseif diff ~= "" then
			diffs[file] = diff
		end
	end

	for _, file in ipairs(untracked_files) do
		local success, file_content = pcall(vim.fn.system, "cat " .. vim.fn.shellescape(file))
		if not success then
			print_error("Failed to read file " .. file .. ": " .. file_content)
		elseif file_content ~= "" then
			diffs[file] = file_content
		end
	end

	if vim.tbl_isempty(diffs) then
		print_error("No changes detected in the repository")
		return
	end

	local diff_str = ""
	for file_path, diff in pairs(diffs) do
		diff_str = diff_str .. "# " .. file_path .. "\n" .. diff .. "\n\n"
	end

	diff_str = sanitize_diff(diff_str)
	local prompt = PROMPT:gsub("#diffs#", diff_str)

	-- copy the prompt to the clipboard
	local success = pcall(vim.fn.setreg, "+", prompt)
	if not success then
		print_error("Failed to copy prompt to clipboard")
	end

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
					local success, err =
						pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { lines[i] })
					if not success then
						print_error("Failed to update buffer: " .. err)
						return
					end
					line_number = line_number + 1
				end
				-- Keep the last incomplete line in current_line
				current_line = lines[#lines]
			end

			-- If the chunk ends with a newline, write the current line and reset it
			if chunk:match("\n$") then
				local success, err =
					pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { current_line })
				if not success then
					print_error("Failed to update buffer: " .. err)
					return
				end
				line_number = line_number + 1
				current_line = ""
			end

			-- Always ensure the current incomplete line is visible
			local success, err =
				pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { current_line })
			if not success then
				print_error("Failed to update buffer: " .. err)
			end
		end)
	end

	vim.schedule(function()
		vim.notify("Generating commit message...")
		local request_body = {
			model = model_name,
			max_tokens = 800,
			system = prompt,
			stream = true,
			messages = {
				{
					role = "user",
					content = "Generate the commit",
				},
			},
		}

		local success, post_data = pcall(vim.fn.json_encode, request_body)
		if not success then
			print_error("Failed to encode request body: " .. post_data)
			return
		end

		local curl = require("plenary.curl")
		local headers = {
			["Content-Type"] = "application/json",
			["anthropic-version"] = "2023-06-01",
			["x-api-key"] = CLAUDE_API_KEY,
		}

		local success, response = pcall(curl.post, CLAUDE_API_ENDPOINT, {
			body = post_data,
			headers = headers,
			stream = function(err, chunk, _)
				if err then
					print_error("Stream error: " .. vim.inspect(err))
					return
				end
				handle_stream_chunk(chunk, update_message)
			end,
		})

		if not success then
			print_error("Failed to make API request: " .. vim.inspect(response))
		end
	end)
end

-- Add this function to handle Gemini API responses
local function handle_gemini_response(data, callback)
	if data == nil then
		print_info("Generation completed")
		callback("")
		return
	end

	vim.schedule(function()
		local success, decoded = pcall(vim.json.decode, data)
		if success then
			if
				decoded.candidates
				and decoded.candidates[1]
				and decoded.candidates[1].content
				and decoded.candidates[1].content.parts
				and decoded.candidates[1].content.parts[1]
				and decoded.candidates[1].content.parts[1].text
			then
				callback(decoded.candidates[1].content.parts[1].text)
			else
				print_error("Unexpected response structure: " .. vim.inspect(decoded))
			end
		else
			print_error("Failed to decode JSON: " .. tostring(decoded))
		end
	end)
end

local function sanitize_diff_for_api(diff_str)
    if not diff_str then
        print_error("No diff string provided")
        return ""
    end

    -- For the API payload, encode special characters differently
    -- Use JSON escaping rather than Lua pattern escaping
    local sanitized = diff_str:gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("\n", "\\n")

    return sanitized
end

-- Add this function for Gemini-powered commit writing
local function gemini_commit_writer()
	if not check_git_environment() then
		return
	end

<<<<<<< HEAD
	-- Check if GEMINI_API_KEY is set
	if not GEMINI_API_KEY or GEMINI_API_KEY == "" then
		print_error("GEMINI_API_KEY environment variable is not set")
		return
	end
=======
    local function sanitize_git_output(output)
        if not output then return "" end
        local normalized = output:gsub("\r\n", "\n")
        normalized = normalized:gsub("%%", "%%%%")

        return normalized
    end


    -- Check if GEMINI_API_KEY is set
    if not GEMINI_API_KEY or GEMINI_API_KEY == "" then
        print_error("GEMINI_API_KEY environment variable is not set")
        return
    end
>>>>>>> 109acd6 (feat(commit-writer): improve commit message generation)

	local current_buffer_name = vim.api.nvim_buf_get_name(0)
	if current_buffer_name:find("COMMIT_EDITMSG") == nil then
		print_error("Please open the COMMIT_EDITMSG buffer to use the commit writer")
		return
	end

	local diffs = {}
	local success, branch_name = pcall(vim.fn.system, "git symbolic-ref --short HEAD")
	if not success then
		print_error("Failed to get branch name: " .. branch_name)
		return
	end
	branch_name = branch_name:gsub("\n$", "")

	local success, git_repo_path = pcall(vim.fn.system, "git rev-parse --show-prefix")
	if not success then
		print_error("Failed to get repo path: " .. git_repo_path)
		return
	end
	git_repo_path = git_repo_path:gsub("\n$", "")

	local success, modified_files = pcall(vim.fn.systemlist, "git diff --cached --name-only")
	if not success then
		print_error("Failed to get modified files: " .. vim.inspect(modified_files))
		return
	end

	local success, untracked_files = pcall(vim.fn.systemlist, "git ls-files --others --exclude-standard")
	if not success then
		print_error("Failed to get untracked files: " .. vim.inspect(untracked_files))
		return
	end

<<<<<<< HEAD
	for _, file in ipairs(modified_files) do
		local success, diff = pcall(vim.fn.system, "git diff --cached " .. vim.fn.shellescape(file))
		if not success then
			print_error("Failed to get diff for file " .. file .. ": " .. diff)
		elseif diff ~= "" then
			diffs[file] = diff
		end
	end

	for _, file in ipairs(untracked_files) do
		local success, file_content = pcall(vim.fn.system, "cat " .. vim.fn.shellescape(file))
		if not success then
			print_error("Failed to read file " .. file .. ": " .. file_content)
		elseif file_content ~= "" then
			diffs[file] = file_content
		end
	end
=======
    for _, file in ipairs(modified_files) do
        -- Make sure to continue in case of any lock file like bun.lock, package-lock.json
        if file:find(".lock") then
            goto continue
        end

        local success, diff = pcall(vim.fn.system, "git diff --cached " .. vim.fn.shellescape(file))
        if not success then
            print_error("Failed to get diff for file " .. file .. ": " .. diff)
            goto continue
        elseif diff == "" then
            goto continue
        end

        -- Get the full content of the HEAD commit version of the file
        local success_head, head_content = pcall(vim.fn.system, "git show HEAD:" .. vim.fn.shellescape(file))
        if not success_head then
            print_error("Failed to get HEAD content for file " .. file .. ": " .. head_content)
            goto continue
        end

        head_content = format_git_output(head_content)

        local formatted_content = "--- Before File ---\n\n"
            .. head_content
            .. "\n\n--- Before File ---\n\n"
            .. "--- Current Staged File ---\n\n"
            .. diff
            .. "\n\n--- Current Staged File ---"

        diffs[file] = formatted_content

        ::continue::
    end

    for _, file in ipairs(untracked_files) do
        -- Make sure to continue in case of any lock file like bun.lock, package-lock.json
        if file:find(".lock") then
            goto continue
        end

        local success, file_content = pcall(vim.fn.system, "cat " .. vim.fn.shellescape(file))
        if not success then
            print_error("Failed to read file " .. file .. ": " .. file_content)
            goto continue
        elseif file_content == "" then
            goto continue
        end

        file_content = sanitize_git_output(file_content)
        diffs[file] = file_content

        ::continue::
    end
>>>>>>> 109acd6 (feat(commit-writer): improve commit message generation)

	if vim.tbl_isempty(diffs) then
		print_error("No changes detected in the repository")
		return
	end

<<<<<<< HEAD
	local diff_str = ""
	for file_path, diff in pairs(diffs) do
		diff_str = diff_str .. "# " .. file_path .. "\n" .. diff .. "\n\n"
	end

	diff_str = sanitize_diff(diff_str)
	local prompt = PROMPT:gsub("#diffs#", diff_str)
=======
    local diff_str = ""
    for file_path, diff in pairs(diffs) do
        diff_str = diff_str .. "# " .. file_path .. "\n\n" .. diff .. "\n\n"
    end

    -- Write raw formatted diff for debugging
    -- vim.fn.writefile(vim.split(diff_str, "\n"), "diffs_formatted.txt")

    -- Prepare diff for the API payload
    local api_diff_str = sanitize_for_api(diff_str)

    -- Save the sanitized diff_str for debugging
    -- vim.fn.writefile({ api_diff_str }, "diffs_api.txt")

    local prompt = PROMPT:gsub("#diffs#", api_diff_str)
>>>>>>> 109acd6 (feat(commit-writer): improve commit message generation)

	local commit_message = ""
	local current_line = ""
	local line_number = nil

	local function update_message(text)
		if text == nil or text == "" then
			return
		end

		commit_message = commit_message .. text

		vim.schedule(function()
			-- Initialize line number if not set
			if not line_number then
				local pos = vim.api.nvim_win_get_cursor(0)
				line_number = pos[1] - 1 -- Convert to 0-based index
			end

			-- Split the text by newlines and process each line
			local lines = vim.split(text, "\n", { plain = true })

			for i, line in ipairs(lines) do
				if i == 1 then
					-- Append to current line for the first segment
					current_line = current_line .. line

					-- Only update if this is not the only line
					if #lines > 1 then
						local success, err =
							pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { current_line })
						if not success then
							print_error("Failed to update buffer: " .. err)
							return
						end
						line_number = line_number + 1
						current_line = ""
					end
				elseif i < #lines then
					-- For middle lines, set them directly
					local success, err =
						pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { line })
					if not success then
						print_error("Failed to update buffer: " .. err)
						return
					end
					line_number = line_number + 1
				else
					-- For the last line, set as current_line
					current_line = line
				end
			end

			-- Always ensure the current incomplete line is visible
			local success, err =
				pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false, { current_line })
			if not success then
				print_error("Failed to update buffer: " .. err)
			end
		end)
	end

	vim.schedule(function()
		vim.notify("Generating commit message with Gemini...")

		local request_body = {
			contents = {
				{
					role = "user",
					parts = {
						{
							text = prompt .. "\n\nGenerate the commit",
						},
					},
				},
			},
			generationConfig = {
				temperature = 0.7,
				topK = 40,
				topP = 0.95,
				maxOutputTokens = 800,
				responseMimeType = "text/plain",
			},
		}

		local success, post_data = pcall(vim.fn.json_encode, request_body)
		if not success then
			print_error("Failed to encode request body: " .. post_data)
			return
		end

		local curl = require("plenary.curl")
		local headers = {
			["Content-Type"] = "application/json",
		}

		local api_url = GEMINI_API_ENDPOINT .. "?key=" .. GEMINI_API_KEY

		local success, response = pcall(curl.post, api_url, {
			body = post_data,
			headers = headers,
			callback = function(data, err)
				if err then
					print_error("API error 1: " .. vim.inspect(err))
					return
				end

				if data.status == 200 then
					-- Successful response
					handle_gemini_response(data.body, update_message)
				else
					print_error("API error 2: " .. vim.inspect(data))
				end
			end,
		})

		if not success then
			print_error("Failed to make API request: " .. vim.inspect(response))
		end
	end)
end

vim.keymap.set("n", "<leader>gw", function()
	gemini_commit_writer()
end, { silent = true, desc = "Generate commit message with Gemini" })

-- vim.keymap.set("n", "<leader>gw", function()
-- 	local model_name = "claude-3-5-haiku-20241022"
-- 	commit_writer(model_name)
-- end, { silent = true })

vim.keymap.set("n", "<leader>so", "<cmd>so %<cr>", { silent = true })
