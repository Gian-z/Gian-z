-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}

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
config["nvim-notify"] = require "plugins.nvim-notify"
config.trouble = require "plugins.trouble"
config["nvim-treesitter"] = require "plugins.treesitter"
config["indent-blankline"] = require "plugins.blankline"
config["nvim-scrollview"] = require "plugins.scrollview"
config.nui = { "MunifTanjim/nui.nvim", lazy = true }

-- Navigation
config.flash = require "plugins.flash"
config.oil = require "plugins.oil"
config["neo-tree"] = require "plugins.neotree"
config.harpoon = require "plugins.harpoon"
config.neoscroll = require "plugins.neoscroll"
config.telescope = require "plugins.telescope"
config["todo-comments"] = require "plugins.todo"
config["which-key"] = require "plugins.whichkey"
config["cheatsheet"] = { "sudormrfbin/cheatsheet.nvim" }
config.persistence = require "plugins.persistence"

-- Modification
config.comment = require "plugins.comment"
config.surround = require "plugins.nvim-surround"
config["grug-far"] = require "plugins.grug-far"
config.yanky = require "plugins.yanky"
config["nvim-autopairs"] = require "plugins.nvim-autopairs"
config["blink-cmp"] = require "plugins.blink"
config.mini = require "plugins.mini"
config.schemastore = require "plugins.schemastore"

config.gitsigns = require "plugins.gitsigns"
config.neogit = require "plugins.neogit"

config["typst-preview"] = require "plugins.typst-preview"
config["markdown-preview"] = require "plugins.md-preview"
config["render-markdown"] = require "plugins.render-markdown"
config["flutter-tools"] = require "plugins.flutter-tools"
config["rust-tools"] = require "plugins.rust-tools"
config.conform = require "plugins.conform"
config["nvim-lint"] = require "plugins.nvim-lint"

-- AI / Debugging / Testing
config.claudecode = require "plugins.claudecode"
config.dap = require "plugins.dap"
config.neotest = require "plugins.neotest"

-- Editing extras
config["ts-context"] = require "plugins.ts-context"
config.diffview = require "plugins.diffview"
config.aerial = require "plugins.aerial"
config["roslyn"] = require "plugins.roslyn"

-- Colorschemes
config["ayu"] = { "ayu-theme/ayu-vim", lazy = true }
config["cyberdream"] = { "scottmckendry/cyberdream.nvim", lazy = true }
config["github-theme"] = { "projekt0n/github-nvim-theme", lazy = true }
config["gruvbox"] = { "ellisonleao/gruvbox.nvim", lazy = true }
config["kanagawa"] = { "rebelot/kanagawa.nvim", lazy = true }
config["miasma"] = { "xero/miasma.nvim", lazy = true }
config["monet"] = { "fynnfluegge/monet.nvim", lazy = true }
config["nightfox"] = { "EdenEast/nightfox.nvim", lazy = true }
config["tokyonight"] = { "folke/tokyonight.nvim", lazy = true }

Ice.plugins = config
