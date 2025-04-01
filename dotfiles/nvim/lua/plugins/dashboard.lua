return {
    "nvimdev/dashboard-nvim",
    lazy = false,
    opts = {
        theme = "hyper",
        config = {
            -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=icenvim
            header = {
              " ",
              "              .__         ",
              "___________  _|__| _____  ",
              "\\___   /\\  \\/ /  |/     \\ ",
              " /    /  \\   /|  |  Y Y  \\",
              "/_____ \\  \\_/ |__|__|_|  /",
              "      \\/               \\/ ",
              " ",
            },
            shortcut = {
                {
                    group = "DiagnosticHint",
                    icon = " ",
                    desc = "Find Files",
                    action = "Telescope find_files",
                    key = 'f'
                },
                {
                    group = "DiagnosticHint",
                    icon = " ",
                    desc = "Lazy Profile",
                    action = "Lazy profile",
                    key = 'l'
                },
                {
                    group = "DiagnosticHint",
                    icon = " ",
                    desc = "Mason",
                    action = "Mason",
                    key = 'm'
                }
            },
            footer = { ":3" },
        },
    },
    config = function(_, opts)
        require("dashboard").setup(opts)

        -- Force the footer to be non-italic
        -- Dashboard loads before the colorscheme plugin, so we should defer the setting of the highlight group to when
        -- all plugins are finished loading
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            once = true,
            callback = function()
                -- Use the highlight command to replace instead of overriding the original highlight group
                -- Much more convenient than using vim.api.nvim_set_hl()
                vim.cmd "highlight DashboardFooter cterm=NONE gui=NONE"
            end,
        })
    end,
}
