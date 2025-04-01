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
config.floaterm = require "plugins.floaterm"

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
        require("notify").setup(opts)
        vim.notify = require "notify"
    end,
}

config["nvim-transparent"] = require "plugins.transparent"
config["nvim-tree"] = require "plugins.tree"
config["nvim-treesitter"] = require "plugins.treesitter"
config.telescope = require "plugins.telescope"
config["todo-comments"] = require "plugins.todo"
config.undotree = require "plugins.undotree"
config["which-key"] = require "plugins.whichkey"
config.lazygit = require "plugins.lazygit"

config.surround = {
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
    event = "User IceLoad",
}

config["tokyonight"] = {
    "folke/tokyonight.nvim",
    lazy = true,
}

config["cheatsheet"] = {
    "sudormrfbin/cheatsheet.nvim"
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
