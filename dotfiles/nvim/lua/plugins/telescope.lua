return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "LinArcX/telescope-env.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "debugloop/telescope-undo.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && "
                .. "cmake --build build --config Release && "
                .. "cmake --install build --prefix build",
        },
    },
    -- ensure that other plugins that use telescope can function properly
    cmd = "Telescope",
    -- Load shortly after startup so telescope-ui-select can hijack
    -- vim.ui.select before any LSP code action / picker call.
    event = "User IceLoad",
    opts = {
        defaults = {
            initial_mode = "insert",
            -- Show the file name up front, with its directory dimmed and
            -- trailing, instead of a leading full path that's hard to scan.
            -- Inherited by every picker that doesn't set its own path_display.
            path_display = { "filename_first" },
            mappings = {
                i = {
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                    ["<C-n>"] = "cycle_history_next",
                    ["<C-p>"] = "cycle_history_prev",
                    ["<C-c>"] = "close",
                    ["<C-u>"] = "preview_scrolling_up",
                    ["<C-d>"] = "preview_scrolling_down",
                },
            },
        },
        pickers = {
            find_files = {
                winblend = 20,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    },
    config = function(_, opts)
        opts.extensions = opts.extensions or {}
        opts.extensions["ui-select"] = { require("telescope.themes").get_dropdown {} }
        local telescope = require "telescope"
        telescope.setup(opts)
        telescope.load_extension "fzf"
        telescope.load_extension "env"
        telescope.load_extension "ui-select"
        telescope.load_extension "undo"
    end,
    keys = {
        { "<Leader><Leader>", "<Cmd>Telescope find_files<CR>", desc = "find file", silent = true, noremap = true },
        { "<Leader>t", "<Cmd>Telescope live_grep<CR>", desc = "live grep", silent = true, noremap = true },
        { "<Leader>e", "<Cmd>Telescope env<CR>", desc = "environment variables", silent = true, noremap = true },
        { "<Leader>u/", "<Cmd>Telescope undo<CR>", desc = "undo history", silent = true, noremap = true },
    },
}
