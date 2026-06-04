return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "<leader>E", "<Cmd>Neotree toggle<CR>", desc = "explorer toggle", silent = true, noremap = true },
        {
            "<leader>uE",
            "<Cmd>Neotree reveal<CR>",
            desc = "explorer reveal current file",
            silent = true,
            noremap = true,
        },
    },
    opts = {
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },
        window = {
            width = 32,
            mappings = {
                ["<space>"] = "none",
                ["o"] = "open",
            },
        },
        default_component_configs = {
            indent = { with_markers = true, with_expanders = true },
            git_status = {
                symbols = {
                    added = "+",
                    modified = "~",
                    deleted = "-",
                    renamed = "→",
                    untracked = "?",
                    ignored = "i",
                    unstaged = "U",
                    staged = "S",
                    conflict = "!",
                },
            },
        },
    },
}
