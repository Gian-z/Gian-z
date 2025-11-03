local utils = require "core.utils"

local config_path = string.gsub(vim.fn.stdpath "config", "\\", "/")

-- Yanking on windows / wsl
local clip_path = config_path .. "/bin/uclip.exe"
if not require("core.utils").file_exists(clip_path) then
    local root
    if utils.is_windows() then
        root = "C:"
    else
        root = "/mnt/c"
    end
    clip_path = root .. "/Windows/System32/clip.exe"
end

if utils.is_windows() or utils.is_wsl() then
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            if vim.v.event.operator == "y" then
                vim.fn.system(clip_path, vim.fn.getreg "0")
            end
        end,
    })
else
    vim.cmd "set clipboard+=unnamedplus"
end

-- IME switching on windows / wsl
if utils.is_windows() or utils.is_wsl() then
    local im_select_path = config_path .. "/bin/im-select.exe"

    if require("core.utils").file_exists(im_select_path) then
        local ime_autogroup = vim.api.nvim_create_augroup("ImeAutoGroup", { clear = true })

        local function autocmd(event, code)
            vim.api.nvim_create_autocmd(event, {
                group = ime_autogroup,
                callback = function()
                    vim.cmd(":silent :!" .. im_select_path .. " " .. code)
                end,
            })
        end

        autocmd("InsertLeave", 1033)
        autocmd("InsertEnter", 2052)
        autocmd("VimLeavePre", 2052)
    end
elseif utils.is_mac() then
    if vim.fn.executable "im-select" == 1 then
        local ime_autogroup = vim.api.nvim_create_augroup("ImeAutoGroup", { clear = true })

        vim.api.nvim_create_autocmd("InsertLeave", {
            group = ime_autogroup,
            callback = function()
                vim.system({ "im-select" }, { text = true }, function(out)
                    Ice.__PREVIOUS_IM_CODE_MAC = string.gsub(out.stdout, "\n", "")
                end)
                vim.cmd ":silent :!im-select com.apple.keylayout.ABC"
            end,
        })

        vim.api.nvim_create_autocmd("InsertEnter", {
            group = ime_autogroup,
            callback = function()
                if Ice.__PREVIOUS_IM_CODE_MAC then
                    vim.cmd(":silent :!im-select " .. Ice.__PREVIOUS_IM_CODE_MAC)
                end
                Ice.__PREVIOUS_IM_CODE_MAC = nil
            end,
        })
    end
elseif utils.is_linux() then
    vim.cmd [[
        let fcitx5state=system("fcitx5-remote")
        autocmd InsertLeave * :silent let fcitx5state=system("fcitx5-remote")[0] | silent !fcitx5-remote -c
        autocmd InsertEnter * :silent if fcitx5state == 2 | call system("fcitx5-remote -o") | endif
    ]]
end

-- Clears redundant shada.tmp.X files (for windows only)
if utils.is_windows() then
    local remove_shada_tmp_group = vim.api.nvim_create_augroup("RemoveShadaTmp", { clear = true })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = remove_shada_tmp_group,
        callback = function()
            local dir = vim.fn.stdpath "data" .. "/shada/"
            local shada_dir = vim.uv.fs_scandir(dir)

            local shada_temp = ""
            while shada_temp ~= nil do
                if string.find(shada_temp, ".tmp.") then
                    local full_path = dir .. shada_temp
                    os.remove(full_path)
                end
                shada_temp = vim.uv.fs_scandir_next(shada_dir)
            end
        end,
    })
end

vim.api.nvim_create_user_command("IceUpdate", "lua require('core.utils').update()", { nargs = 0 })
vim.api.nvim_create_user_command("IceHealth", "checkhealth core", { nargs = 0 })
