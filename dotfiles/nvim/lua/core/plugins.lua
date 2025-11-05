-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}
---@diagnostic disable-next-line: unused-local
local config_root = string.gsub(vim.fn.stdpath "config" --[[@as string]], "\\", "/")
---@diagnostic disable-next-line: unused-local
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

-- Core
config.lspsaga = require "plugins.lspsaga"
config.mason = require "plugins.mason"

-- UI
config.bufferline = require "plugins.bufferline"
config.colorizer = require "plugins.colorizer"
config.dashboard = require "plugins.dashboard"
config.fidget = require "plugins.fidget"
config.lualine = require "plugins.lualine"
config.trouble = require "plugins.trouble"
config["nvim-treesitter"] = require "plugins.treesitter"
config["indent-blankline"] = require "plugins.blankline"
config["nvim-notify"] = require "plugins.nvim-notify"
config["nvim-scrollview"] = require "plugins.scrollview"
config.nui = { "MunifTanjim/nui.nvim", lazy = true }

-- Navigation
config.hop = require "plugins.hop"
config.oil = require "plugins.oil"
config.harpoon = require "plugins.harpoon"
config.neoscroll = require "plugins.neoscroll"
config.telescope = require "plugins.telescope"
config["todo-comments"] = require "plugins.todo"
config["which-key"] = require "plugins.whichkey"
config["cheatsheet"] = { "sudormrfbin/cheatsheet.nvim" }

-- Modification
config.comment = require "plugins.comment"
config.surround = require "plugins.nvim-surround"
config["grug-far"] = require "plugins.grug-far"
config["nvim-autopairs"] = require "plugins.nvim-autopairs"
config["nvim-cmp"] = require "plugins.nvim-cmp"

config.gitsigns = require "plugins.gitsigns"
config.neogit = require "plugins.neogit"

config["typst-preview"] = require "plugins.typst-preview"
config["markdown-preview"] = require "plugins.md-preview"
config["flutter-tools"] = require "plugins.flutter-tools"
config["rust-tools"] = require "plugins.rust-tools"
config["null-ls"] = require "plugins.null-ls"

-- Colorschemes
config["cyberdream"] = { "scottmckendry/cyberdream.nvim", lazy = true }
config["gruvbox"] = { "ellisonleao/gruvbox.nvim", lazy = true }
config["kanagawa"] = { "rebelot/kanagawa.nvim", lazy = true }
config["miasma"] = { "xero/miasma.nvim", lazy = true }
config["monet"] = { "fynnfluegge/monet.nvim", lazy = true }
config["nightfox"] = { "EdenEast/nightfox.nvim", lazy = true }
config["tokyonight"] = { "folke/tokyonight.nvim", lazy = true }

Ice.plugins = config
