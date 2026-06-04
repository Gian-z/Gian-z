return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "Issafalcon/neotest-dotnet",
        "rouge8/neotest-rust",
        "nvim-neotest/neotest-go",
    },
    keys = {
        {
            "<leader>nr",
            function()
                require("neotest").run.run()
            end,
            desc = "run nearest",
        },
        {
            "<leader>nf",
            function()
                require("neotest").run.run(vim.fn.expand "%")
            end,
            desc = "run file",
        },
        {
            "<leader>nd",
            function()
                require("neotest").run.run { strategy = "dap" }
            end,
            desc = "debug nearest",
        },
        {
            "<leader>ns",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "toggle summary",
        },
        {
            "<leader>no",
            function()
                require("neotest").output.open { enter = true }
            end,
            desc = "open output",
        },
        {
            "<leader>nO",
            function()
                require("neotest").output_panel.toggle()
            end,
            desc = "toggle output panel",
        },
        {
            "<leader>nt",
            function()
                require("neotest").run.stop()
            end,
            desc = "stop",
        },
    },
    config = function()
        require("neotest").setup {
            adapters = {
                require "neotest-dotnet" {
                    dap = { adapter_name = "netcoredbg" },
                },
                require "neotest-rust",
                require "neotest-go",
            },
        }
    end,
}
