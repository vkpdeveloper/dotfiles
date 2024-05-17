local js_based_languages = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
}

return {
    "mfussenegger/nvim-dap",
    config = function()
        local dap = require("dap")

        -- local Config = require("lazyvim.config")
        -- vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
        --
        -- for name, sign in pairs(Config.icons.dap) do
        --     sign = type(sign) == "table" and sign or { sign }
        --     vim.fn.sign_define(
        --         "Dap" .. name,
        --         { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        --     )
        -- end

        for _, language in ipairs(js_based_languages) do
            dap.configurations[language] = {
                -- Debug single nodejs files
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    cwd = vim.fn.getcwd(),
                    sourceMaps = true,
                },
                -- Debug nodejs processes (make sure to add --inspect when you run the process)
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach",
                    processId = require("dap.utils").pick_process,
                    cwd = vim.fn.getcwd(),
                    sourceMaps = true,
                },
                -- Debug web applications (client side)
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch & Debug Chrome",
                    url = function()
                        local co = coroutine.running()
                        return coroutine.create(function()
                            vim.ui.input({
                                prompt = "Enter URL: ",
                                default = "http://localhost:3000",
                            }, function(url)
                                if url == nil or url == "" then
                                    return
                                else
                                    coroutine.resume(co, url)
                                end
                            end)
                        end)
                    end,
                    webRoot = vim.fn.getcwd(),
                    protocol = "inspector",
                    sourceMaps = true,
                    userDataDir = false,
                },

                {
                    name = "----- ↓ launch.json configs ↓ -----",
                    type = "",
                    request = "launch",
                },
            }
        end
    end,
    keys = {
        {
            "<leader>dO",
            function()
                require("dap").step_out()
            end,
            desc = "Step Out",
        },
        {
            "<leader>do",
            function()
                require("dap").step_over()
            end,
            desc = "Step Over",
        },
        {
            "<leader>da",
            function()
                if vim.fn.filereadable(".vscode/launch.json") then
                    local dap_vscode = require("dap.ext.vscode")
                    dap_vscode.load_launchjs(nil, {
                        ["pwa-node"] = js_based_languages,
                        ["chrome"] = js_based_languages,
                        ["pwa-chrome"] = js_based_languages,
                    })
                end
                require("dap").continue()
            end,
            desc = "Run with Args",
        },
    },
    dependencies = {
        "nvim-neotest/nvim-nio",
        -- Install the vscode-js-debug adapter
        {
            "microsoft/vscode-js-debug",
            -- After install, build it and rename the dist directory to out
            build =
            "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
            version = "1.*",
        },
        {
            "mxsdev/nvim-dap-vscode-js",
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require("dap-vscode-js").setup({
                    -- Path of node executable. Defaults to $NODE_PATH, and then "node"
                    -- node_path = "node",

                    -- Path to vscode-js-debug installation.
                    debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

                    -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
                    -- debugger_cmd = { "js-debug-adapter" },

                    -- which adapters to register in nvim-dap
                    adapters = {
                        "chrome",
                        "pwa-node",
                        "pwa-chrome",
                        "pwa-msedge",
                        "pwa-extensionHost",
                        "node-terminal",
                    },

                    -- Path for file logging
                    -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

                    -- Logging level for output to file. Set to false to disable logging.
                    -- log_file_level = false,

                    -- Logging level for output to console. Set to false to disable console output.
                    -- log_console_level = vim.log.levels.ERROR,
                })
            end,
        },
        {
            "Joakker/lua-json5",
            build = "./install.sh",
        },
        -- virtual text
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },
        -- mason.nvim integration
        {
            "jay-babu/mason-nvim-dap.nvim",
            dependencies = "mason.nvim",
            cmd = { "DapInstall", "DapUninstall" },
            opts = {
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_installation = true,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {},

                -- You'll need to check that you have the required things installed
                -- online, please don't ask me how to install them :)
                ensure_installed = {
                    -- Update this to ensure that you have the debuggers for the langs you want
                },
            },
        },
        -- neoconf for launch.json parser
        {
            "folke/neoconf.nvim",
        },
        {
            "rcarriga/nvim-dap-ui",
            config = function()
                local dap, dapui = require("dap"), require("dapui")

                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end

                vim.keymap.set('n', '<leader>ui', require 'dapui'.toggle)
                require("dapui").setup()
            end,
        }
    },
}
