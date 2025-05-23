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

    <footer>

    -- RULES --
    - make sure to follow the format and only respond in the given format and nothing else should be there in the resoonse.
    - type, scope and subject are mandatory
    - make sure the subject is less than 50 characters
    - body is under 350 characters

    -- INPUT --

    #diffs#
]]

CLAUDE_API_ENDPOINT = "https://api.anthropic.com/v1/messages"
CLAUDE_API_KEY = vim.env.CLAUDE_API_KEY

local function split_into_lines(text)
    local lines = {}
    -- This pattern matches text between newlines, including empty lines
    for line in (text .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    return lines
end

local function commit_writer(model_name)
    --[[
        IDEA: an ai based commit writer based on code diffs in all the git changes
        1. get all modified files from git with exact diffs
        2. use ollama to generate commit message based on the collected diffs
        3. insert the commit message in the git COMMIT_EDITING buffer
    ]] --

    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    if current_buffer_name:find("COMMIT_EDITMSG") == nil then
        vim.notify("Please open the COMMIT_EDITMSG buffer to use the commit writer.")
        return
    end

    local diffs = {}

    local branch_name = vim.fn.system("git symbolic-ref --short HEAD"):gsub("\n$", "")

    local git_repo_path = vim.fn.system('git rev-parse --show-prefix'):gsub("\n$", "")
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
    vim.fn.setreg('+', prompt)

    vim.schedule(function()
        vim.notify("Generating commit message...")
        -- First, create a proper table structure
        local request_body = {
            model = "claude-3-5-sonnet-20241022",
            max_tokens = 300,
            system = prompt,
            stream = false,
            messages = {
                {
                    role = "user",
                    content = "Generate the commit"
                }
            }
        }

        -- Convert to JSON properly using vim.fn.json_encode
        local post_data = vim.fn.json_encode(request_body)

        -- Make the curl request with proper escaping
        local response = vim.fn.system({
            "curl",
            "-s",
            "-X", "POST",
            "-H", "Content-Type: application/json",
            "-H", "anthropic-version: 2023-06-01",
            "-H", "x-api-key: " .. CLAUDE_API_KEY,
            "-d", post_data,
            CLAUDE_API_ENDPOINT
        })

        local json_response = vim.fn.json_decode(response)
        local commit_message = json_response.content[1].text
        commit_message = split_into_lines(commit_message)

        -- Insert the commit message in the buffer
        local cursor_pos = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, cursor_pos, cursor_pos, false, commit_message)
        vim.notify('commit message generated')
    end)
end

vim.keymap.set("n", "<leader>gw", function()
    local model_name = "qwen2.5-coder:7b"
    -- local model_name = "llama3.2:latest"
    commit_writer(model_name)
end, { silent = true })

vim.keymap.set('n', '<leader>so', '<cmd>so %<cr>', { silent = true })
