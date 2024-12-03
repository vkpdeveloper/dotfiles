-- First, let's create a module to manage our progress bar
local M = {}

-- This function creates our progress bar window and returns controls
function M.create_progress_bar()
    -- Create a new buffer for our progress bar
    local buf = vim.api.nvim_create_buf(false, true)

    -- Calculate the window dimensions and position
    local width = 60
    local height = 3
    local win_width = vim.api.nvim_get_option("columns")
    local win_height = vim.api.nvim_get_option("lines")

    -- Center the window
    local row = math.floor((win_height - height) / 2)
    local col = math.floor((win_width - width) / 2)

    -- Configure the floating window
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, false, opts)

    -- Add some initial styling
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:Normal')

    -- Return a table with functions to control the progress bar
    return {
        -- Update the progress
        update = function(current, total, message)
            -- Calculate the percentage
            local percentage = math.floor((current / total) * 100)

            -- Create the progress bar (40 characters wide)
            local bar_width = 40
            local filled = math.floor((percentage * bar_width) / 100)
            local bar = string.rep('█', filled) .. string.rep('░', bar_width - filled)

            -- Create the display lines
            local lines = {
                message or "Processing...",
                bar,
                percentage .. "% completed"
            }

            -- Update the buffer content
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        end,

        -- Close and clean up the progress bar
        close = function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    }
end

-- Here's a function to demonstrate how to use the progress bar
function M.demo_progress()
    -- Create our progress bar
    local progress = M.create_progress_bar()

    -- Simulate some work with progress updates
    local total_steps = 100
    for i = 0, total_steps do
        -- Update the progress bar
        progress.update(i, total_steps, "Processing items...")

        -- Simulate some work
        vim.defer_fn(function()
            if i == total_steps then
                -- Clean up when we're done
                progress.close()
                print("Processing complete!")
            end
        end, i * 50) -- Delay increases with each step
    end
end

return M
