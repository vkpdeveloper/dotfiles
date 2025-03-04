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
                    local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                        { lines[i] })
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
                local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                    { current_line })
                if not success then
                    print_error("Failed to update buffer: " .. err)
                    return
                end
                line_number = line_number + 1
                current_line = ""
            end

            -- Always ensure the current incomplete line is visible
            local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                { current_line })
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
            if decoded.candidates and decoded.candidates[1] and
                decoded.candidates[1].content and
                decoded.candidates[1].content.parts and
                decoded.candidates[1].content.parts[1] and
                decoded.candidates[1].content.parts[1].text then
                callback(decoded.candidates[1].content.parts[1].text)
            else
                print_error("Unexpected response structure: " .. vim.inspect(decoded))
            end
        else
            print_error("Failed to decode JSON: " .. tostring(decoded))
        end
    end)
end

-- Add this function for Gemini-powered commit writing
local function gemini_commit_writer()
    if not check_git_environment() then
        return
    end

    -- Check if GEMINI_API_KEY is set
    if not GEMINI_API_KEY or GEMINI_API_KEY == "" then
        print_error("GEMINI_API_KEY environment variable is not set")
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
                        local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                            { current_line })
                        if not success then
                            print_error("Failed to update buffer: " .. err)
                            return
                        end
                        line_number = line_number + 1
                        current_line = ""
                    end
                elseif i < #lines then
                    -- For middle lines, set them directly
                    local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                        { line })
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
            local success, err = pcall(vim.api.nvim_buf_set_lines, 0, line_number, line_number + 1, false,
                { current_line })
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
                            text = prompt .. "\n\nGenerate the commit"
                        }
                    }
                }
            },
            generationConfig = {
                temperature = 0.7,
                topK = 40,
                topP = 0.95,
                maxOutputTokens = 800,
                responseMimeType = "text/plain"
            }
        }

        local success, post_data = pcall(vim.fn.json_encode, request_body)
        if not success then
            print_error("Failed to encode request body: " .. post_data)
            return
        end

        local curl = require("plenary.curl")
        local headers = {
            ["Content-Type"] = "application/json"
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
            end
        })

        if not success then
            print_error("Failed to make API request: " .. vim.inspect(response))
        end
    end)
end

-- Add this mapping for Gemini
vim.keymap.set("n", "<leader>gg", function()
    gemini_commit_writer()
end, { silent = true, desc = "Generate commit message with Gemini" })

vim.keymap.set("n", "<leader>gw", function()
    local model_name = "claude-3-5-haiku-20241022"
    commit_writer(model_name)
end, { silent = true })

vim.keymap.set("n", "<leader>so", "<cmd>so %<cr>", { silent = true })
