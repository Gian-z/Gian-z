-- Hard requirement: this config uses 0.11+ APIs (winborder, vim.lsp.config/
-- enable, the lsp/*.lua autoload convention, treesitter `main`). Fail fast with
-- an actionable message instead of a cryptic error deep inside some module.
if vim.fn.has "nvim-0.11" == 0 then
    local msg = "This Neovim configuration requires Neovim 0.11 or newer.\n"
        .. "You are running "
        .. tostring(vim.version())
        .. ". Please upgrade Neovim, then restart."
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
    return
end

if vim.loader then
    vim.loader.enable()
end

-- Guarded Ice registry: warns on unknown top-level keys (typo detection).
do
    local known = {
        plugins = true,
        lsp = true,
        keymap = true,
        ft = true,
        lazy = true,
        symbols = true,
        colorschemes = true,
        colorscheme = true,
        auto_chdir = true,
        chdir_exclude_filetype = true,
        chdir_exclude_buftype = true,
        chdir_root_pattern = true,
    }
    local backing = {}
    Ice = setmetatable({}, {
        __index = backing,
        __newindex = function(_, k, v)
            if not known[k] and not tostring(k):match "^__" then
                vim.schedule(function()
                    vim.notify("Ice: unknown key '" .. tostring(k) .. "' (typo?)", vim.log.levels.WARN)
                end)
            end
            backing[k] = v
        end,
    })
end

require "core.init"

-- Define keymap
local keymap = Ice.keymap.general
require("core.utils").group_map(keymap)

for filetype, config in pairs(Ice.ft) do
    require("core.utils").ft(filetype, config)
end

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
    -- Load plugins
    local config = {}
    for _, plugin in pairs(Ice.plugins) do
        config[#config + 1] = plugin
    end
    require("lazy").setup(config, Ice.lazy)

    require("core.utils").group_map(Ice.keymap.plugins)

    -- Define colorscheme
    if not Ice.colorscheme then
        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
        if require("core.utils").file_exists(colorscheme_cache) then
            local colorscheme_cache_file = io.open(colorscheme_cache, "r")
            ---@diagnostic disable: need-check-nil
            local colorscheme = colorscheme_cache_file:read "*a"
            colorscheme_cache_file:close()
            Ice.colorscheme = colorscheme
        else
            Ice.colorscheme = "tokyonight"
        end
    end

    require("core.utils").colorscheme(Ice.colorscheme)
end
