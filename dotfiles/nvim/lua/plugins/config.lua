-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}
local config_root = string.gsub(vim.fn.stdpath "config" --[[@as string]], "\\", "/")
local priority = {
    LOW = 100,
    MEDIUM = 200,
    HIGH = 615,
}

-- Add IceLoad event
-- If user starts neovim but does not edit a file, i.e., entering Dashboard directly, the IceLoad event is hooked to the
-- next BufEnter event. Otherwise, the event is triggered right after the VeryLazy event.
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        local function _trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "IceLoad" })
        end

        if vim.bo.filetype == "dashboard" then
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*/*",
                once = true,
                callback = _trigger,
            })
        else
            _trigger()
        end
    end,
})

config.bufferline = require "plugins.bufferline"
config.colorizer = require "plugins.colorizer"
config.comment = require "plugins.comment"
config.dashboard = require "plugins.dashboard"
config.gitsigns = require "plugins.gitsigns"
config.hop = require "plugins.hop"

config["grug-far"] = {
    "MagicDuck/grug-far.nvim",
    opts = {
        disableBufferLineNumbers = true,
        startInInsertMode = true,
        windowCreationCommand = "tabnew %",
    },
    keys = {
        { "<leader>ug", "<Cmd>GrugFar<CR>", desc = "find and replace", silent = true, noremap = true },
    },
}

config["indent-blankline"] = require "plugins.blankline"
config.lualine = require "plugins.lualine"
config["markdown-preview"] = require "plugins.md-preview"

config.neogit = {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    main = "neogit",
    opts = {
        disable_hint = true,
        status = {
            recent_commit_count = 30,
        },
        commit_editor = {
            kind = "auto",
            show_staged_diff = false,
        },
    },
    keys = {
        { "<leader>gt", "<Cmd>Neogit<CR>", desc = "neogit", silent = true, noremap = true },
    },
    config = function(_, opts)
        require("neogit").setup(opts)
        Ice.ft.NeogitCommitMessage = function()
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end
    end,
}

config.neoscroll = require "plugins.neoscroll"

config.nui = {
    "MunifTanjim/nui.nvim",
    lazy = true,
}

config["nvim-autopairs"] = {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    main = "nvim-autopairs",
    opts = {},
}

config["nvim-notify"] = {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
        timeout = 3000,
        background_colour = "#000000",
        stages = "static",
    },
    config = function(_, opts)
        ---@diagnostic disable-next-line: undefined-field
        require("notify").setup(opts)
        vim.notify = require "notify"
    end,
}

config["nvim-scrollview"] = {
    "dstein64/nvim-scrollview",
    event = "User IceLoad",
    main = "scrollview",
    opts = {
        excluded_filetypes = { "nvimtree" },
        current_only = true,
        winblend = 75,
        base = "right",
        column = 1,
    },
}

config["nvim-transparent"] = require "plugins.transparent"
config["nvim-tree"] = require "plugins.tree"
config["nvim-treesitter"] = require "plugins.treesitter"
config.telescope = require "plugins.telescope"
config["todo-comments"] = require "plugins.todo"
config.undotree = require "plugins.undotree"
config["which-key"] = require "plugins.whichkey"

config.surround = {
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
    event = "User IceLoad",
}

-- Colorschemes
config["ayu"] = {
    "Luxed/ayu-vim",
    lazy = true,
}

config["github"] = {
    "projekt0n/github-nvim-theme",
    lazy = true,
}

config["gruvbox"] = {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
}

config["kanagawa"] = {
    "rebelot/kanagawa.nvim",
    lazy = true,
}

config["nightfox"] = {
    "EdenEast/nightfox.nvim",
    lazy = true,
}

config["tokyonight"] = {
    "folke/tokyonight.nvim",
    lazy = true,
}

Ice.plugins = config
Ice.keymap.prefix = {
    { "<leader>b", group = "+buffer" },
    { "<leader>c", group = "+comment" },
    { "<leader>g", group = "+git" },
    { "<leader>h", group = "+hop" },
    { "<leader>l", group = "+lsp" },
    { "<leader>t", group = "+telescope" },
    { "<leader>u", group = "+utils" },
}
