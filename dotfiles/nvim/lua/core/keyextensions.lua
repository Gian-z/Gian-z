local ret = {}

-- Open the current html file with the default browser.
ret.open_html_file = function()
    if vim.bo.filetype == "html" then
        local utils = require "core.utils"
        local command
        if utils.is_linux() or utils.is_wsl() then
            command = "xdg-open"
        elseif utils.is_windows() then
            command = "explorer"
        else
            command = "open"
        end
        if require("core.utils").is_windows() then
            local old_shellslash = vim.opt.shellslash
            vim.opt.shellslash = false
            vim.api.nvim_command(string.format('silent exec "!%s %%:p"', command))
            vim.opt.shellslash = old_shellslash
        else
            vim.api.nvim_command(string.format('silent exec "!%s %%:p"', command))
        end
    end
end

-- When evoked under normal / insert / visual mode, call vim's `undo` command and then go to normal mode.
ret.undo = function()
    local mode = vim.api.nvim_get_mode().mode

    -- Only undo in normal / insert / visual mode
    if mode == "n" or mode == "i" or mode == "v" then
        vim.cmd "undo"
        -- Back to normal mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end
end

ret.join_lines = function()
    local v_count = vim.v.count1 + 1
    local mode = vim.api.nvim_get_mode().mode
    local keys
    if mode == "n" then
        keys = v_count .. "J"
    else
        keys = "J"
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

ret.get_hoverdoc = function()
    local win = require "lspsaga.window"
    local old_new_float = win.new_float
    win.new_float = function(self, float_opt, enter, force)
        local window = old_new_float(self, float_opt, enter, force)
        local _, winid = window:wininfo()
        vim.api.nvim_set_current_win(winid)

        win.new_float = old_new_float
        return window
    end

    vim.cmd "Lspsaga hover_doc"
end

ret.get_terminalcmd = function()
    if not require("core.utils").is_windows() then
        return "<Cmd>split | terminal<CR>" -- let $SHELL decide the default shell
    else
        local executables = { "pwsh", "powershell", "bash", "cmd" }
        for _, executable in require("core.utils").ordered_pair(executables) do
            if vim.fn.executable(executable) == 1 then
                return "<Cmd>split term://" .. executable .. "<CR>"
            end
        end
    end
end

-- Determine in advance what shell to use for the <C-t> keymap
return ret
