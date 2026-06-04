return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "toggle breakpoint",
        },
        {
            "<leader>dB",
            function()
                require("dap").set_breakpoint(vim.fn.input "Condition: ")
            end,
            desc = "conditional breakpoint",
        },
        {
            "<leader>dc",
            function()
                require("dap").continue()
            end,
            desc = "continue",
        },
        {
            "<leader>di",
            function()
                require("dap").step_into()
            end,
            desc = "step into",
        },
        {
            "<leader>do",
            function()
                require("dap").step_over()
            end,
            desc = "step over",
        },
        {
            "<leader>dO",
            function()
                require("dap").step_out()
            end,
            desc = "step out",
        },
        {
            "<leader>dr",
            function()
                require("dap").repl.open()
            end,
            desc = "open repl",
        },
        {
            "<leader>dl",
            function()
                require("dap").run_last()
            end,
            desc = "run last",
        },
        {
            "<leader>du",
            function()
                require("dapui").toggle()
            end,
            desc = "toggle dap ui",
        },
        {
            "<leader>dt",
            function()
                require("dap").terminate()
            end,
            desc = "terminate",
        },
        {
            "<leader>de",
            function()
                require("dapui").eval()
            end,
            mode = { "n", "v" },
            desc = "eval expression",
        },
    },
    config = function()
        local dap = require "dap"
        local dapui = require "dapui"

        -- DEBUG-level log surfaces the full DAP JSON exchange with the adapter,
        -- which is the only way to see why netcoredbg silently aborts a launch
        -- (bad program path, missing runtimeconfig.json, runtime mismatch, AV).
        dap.set_log_level "DEBUG"
        vim.api.nvim_create_user_command("DapTailLog", function()
            local log = vim.fn.stdpath "cache" .. "/dap.log"
            vim.cmd("tabnew " .. log)
            vim.cmd "normal! G"
        end, { desc = "open dap.log at the tail" })

        dapui.setup()
        require("nvim-dap-virtual-text").setup {}
        require("mason-nvim-dap").setup {
            ensure_installed = { "netcoredbg", "codelldb" },
            automatic_installation = true,
            handlers = {},
        }

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- C# / .NET via netcoredbg (installed by mason-nvim-dap above).
        -- On Windows we point at the real .exe, not Mason's `bin/netcoredbg.cmd`
        -- shim: the .cmd wrapper goes through cmd.exe and breaks DAP's stdio
        -- JSON protocol (the adapter launches but never responds → stall).
        local mason_pkg = vim.fn.stdpath "data" .. "/mason/packages/netcoredbg"
        local netcoredbg_cmd
        if vim.fn.has "win32" == 1 then
            netcoredbg_cmd = mason_pkg .. "/netcoredbg/netcoredbg.exe"
        else
            netcoredbg_cmd = mason_pkg .. "/netcoredbg"
        end
        dap.adapters.netcoredbg = {
            type = "executable",
            command = netcoredbg_cmd,
            args = { "--interpreter=vscode" },
            -- On Windows nvim-dap spawns child processes detached by default;
            -- netcoredbg then loses its parent pipes and exits immediately.
            options = { detached = false },
        }

        -- Walk every *.csproj under cwd and look for its build output dll. We
        -- match dll basename against csproj basename so dependency dlls in the
        -- same bin/Debug aren't proposed as the entry point.
        local function discover_dlls()
            local cwd = vim.fn.getcwd()
            local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
            local results = {}
            for _, proj in ipairs(csprojs) do
                local proj_dir = vim.fn.fnamemodify(proj, ":h")
                local stem = vim.fn.fnamemodify(proj, ":t:r")
                local matches = vim.fn.glob(proj_dir .. "/bin/Debug/**/" .. stem .. ".dll", false, true)
                for _, dll in ipairs(matches) do
                    table.insert(results, dll)
                end
            end
            return results
        end

        -- Async prompt via a coroutine: returning a coroutine from `program`
        -- lets nvim-dap suspend the launch until the user actually answers.
        -- Synchronous vim.fn.input here doesn't work — the <CR> that picks
        -- the configuration in dap.continue's `vim.ui.select` bleeds into
        -- the immediate input prompt and resolves it to "".
        local function prompt_dll()
            local co = coroutine.running()
            vim.schedule(function()
                local candidates = discover_dlls()
                local function finish(path)
                    if not path or path == "" then
                        vim.notify("DAP: no dll selected, aborting launch", vim.log.levels.WARN)
                        coroutine.resume(co, nil)
                        return
                    end
                    if vim.fn.filereadable(path) ~= 1 then
                        vim.notify("DAP: not a file: " .. path .. " (build the project first?)", vim.log.levels.ERROR)
                        coroutine.resume(co, nil)
                        return
                    end
                    coroutine.resume(co, path)
                end

                if #candidates == 1 then
                    finish(candidates[1])
                elseif #candidates > 1 then
                    vim.ui.select(candidates, { prompt = "Pick dll to launch:" }, finish)
                else
                    vim.ui.input(
                        { prompt = "No dll found. Enter path: ", default = vim.fn.getcwd() .. "/", completion = "file" },
                        finish
                    )
                end
            end)
            return coroutine.yield()
        end

        dap.configurations.cs = {
            {
                type = "netcoredbg",
                name = "Launch (pick dll)",
                request = "launch",
                program = prompt_dll,
                cwd = "${workspaceFolder}",
                -- Console apps that finish in ms would terminate the session
                -- before you can do anything; break on entry instead.
                stopAtEntry = true,
                env = {
                    ASPNETCORE_ENVIRONMENT = "Development",
                    DOTNET_ENVIRONMENT = "Development",
                },
            },
            {
                type = "netcoredbg",
                name = "Attach to process",
                request = "attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
            },
        }

        local sign = vim.fn.sign_define
        sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
        sign("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
        sign("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
    end,
}
