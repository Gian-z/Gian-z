local v = vim.version()
local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)

local argv = vim.api.nvim_get_vvar "argv"
local noplugin = false
for i = 3, #argv, 1 do
    if argv[i] == "--noplugin" then
        noplugin = true
        break
    end
end

local utils = {
    noplugin = noplugin,
    version = version,
}

local ft_group = vim.api.nvim_create_augroup("IceFt", { clear = true })

-- Checks if a file exists
---@param file string
---@return boolean
utils.file_exists = function(file)
    local fid = io.open(file, "r")
    if fid ~= nil then
        io.close(fid)
        return true
    else
        return false
    end
end

-- Add callback to filetype
---@param filetype string
---@param config function
utils.ft = function(filetype, config)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        group = ft_group,
        callback = config,
    })
end

-- Get the parent directory of target. If target is nil, the parent directory of the current file will be looked for,
-- suffixed with a "/" (which is because this function is intended to be used together with fs_scandir, where errors
-- would occur sometimes should a path without an ending "/" be passed to it, such as "C:" instead of "C:/").
--
-- If the target has no parent directory, such as "/" on Linux or "C:" on Windows, nil will be returned.
---@param target string?
---@return string?
utils.get_parent = function(target)
    if target == nil then
        local parent = vim.fn.expand("%:p:h", true)

        if utils.is_windows() then
            parent = string.gsub(parent, "\\", "/")
        end

        return parent
    end

    if utils.is_windows() then
        target = string.gsub(target, "\\", "/")
    end

    -- removes trailing slash
    if string.sub(target, #target, #target) == "/" then
        target = string.sub(target, 1, #target - 1)
    end

    if string.find(target, "/") == nil then
        return nil
    end

    return string.sub(target, 1, string.findlast(target, "/"))
end

utils.is_windows = function()
    return vim.uv.os_uname().sysname == "Windows_NT"
end

utils.is_linux = function()
    return vim.uv.os_uname().sysname == "Linux"
end

utils.is_wsl = function()
    return string.find(vim.uv.os_uname().release, "WSL") ~= nil
end

utils.is_mac = function ()
    return vim.uv.os_uname().sysname == "Darwin"
end

-- Maps a group of keymaps with the same opt; if no opt is provided, the default opt is used.
-- The keymaps should be in the format like below:
--     desc = { mode, lhs, rhs, [opt] }
-- For example:
--     black_hole_register = { { "n", "v" }, "\\", '"_' },
-- The desc part will automatically merged into the keymap's opt, unless one is already provided there, with the slight
-- modification of replacing "_" with a blank space.
---@param group table list of keymaps
---@param opt table | nil default opt
utils.group_map = function(group, opt)
    if not opt then
        opt = {}
    end

    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")
        local default_option = vim.tbl_extend("force", {
            desc = desc,
            noremap = true,
            nowait = true,
            silent = true,
        }, opt)
        local map = vim.tbl_deep_extend("force", { nil, nil, nil, default_option }, keymap)
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end

-- Allow ordered iteration through a table
---@param t table
---@return function
utils.ordered_pair = function(t)
    local a = {}

    for n in pairs(t) do
        a[#a + 1] = n
    end

    table.sort(a)

    local i = 0

    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

-- Updates IceNvim
utils.update = function()
    vim.system({ "git", "pull" }, { cwd = vim.fn.stdpath "config", text = true }, function(out)
        if out.code == 0 then
            vim.notify "IceNvim up to date"
        else
            vim.notify("IceNvim update failed: " .. out.stderr, vim.log.levels.WARN)
        end
    end)
end

-- Looks for the last match of `pattern`
-- WARN: this function does poorly with unicode characters!
---@param s string | number
---@param pattern string | number
---@param last integer?
---@param plain boolean?
---@return integer | nil, integer | nil, ... | any
string.findlast = function(s, pattern, last, plain)
    local reverse = string.reverse(s)

    if last == nil then
        last = #s
    end

    local start, finish = string.find(reverse, string.reverse(pattern), #s + 1 - last, plain)
    if start == nil then
        return nil
    else
        return #s + 1 - finish, #s + 1 - start
    end
end

-- Splits the string with the given pattern
-- WARN: this function does poorly with unicode characters!
---@param str string
---@param pattern string
---@return table
string.split = function(str, pattern)
    local start = 1
    ---@diagnostic disable-next-line: redefined-local
    local s, e = string.find(str, pattern, start)
    local ret = {}
    while s ~= nil do
        ret[#ret + 1] = string.sub(str, start, s - 1)
        ---@diagnostic disable-next-line: cast-local-type
        start = e + 1
        s, e = string.find(str, pattern, start)
    end
    if start <= #str then
        ret[#ret + 1] = string.sub(str, start)
    end
    return ret
end

-- Finds the first occurence of the target in table and returns the key / index.
-- If the target is not in the table, nil is returned.
---@param t table
---@param target ... | any
---@return ... | any
table.find = function(t, target)
    for key, value in pairs(t) do
        if value == target then
            return key
        end
    end

    return nil
end

utils.lsp_attach_keymap = function(bufnr)
    require("core.utils").group_map(Ice.keymap.lsp.mapLsp, { noremap = true, silent = true, buffer = bufnr })
end

-- Checks whether a lsp client is active in the current buffer
-- If no lsp is specified, the function checks whether any lsp is attached
---@param lsp string | nil
---@return boolean
utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_clients { bufnr = 0, name = lsp }
    return #active_client > 0
end

-- Use nui popup to check whether nerd font icons look normal
utils.check_icons = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then
        error "The icon-check functionality requires nui.nvim."
    end

    local text = require "nui.text"
    local line = require "nui.line"

    local item_width = 24
    local column_number = math.floor(vim.fn.winwidth(0) / item_width) - 1
    local width = tostring(column_number * item_width)
    local win_height = vim.fn.winheight(0)

    local p = popup {
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Check Nerd Font Icons",
                top_align = "center",
                bottom = "Press q to close window",
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        position = "50%",
        size = {
            width = width,
            height = "60%",
        },
    }

    p:mount()

    local count = 0
    local new_line = line()
    local row
    for name, icon in require("core.utils").ordered_pair(Ice.symbols) do
        row = math.floor(count / column_number) + 1
        local index = count % column_number

        if index == 0 then
            if row ~= 1 then
                new_line:render(p.bufnr, -1, row - 1)
            end

            new_line = line()
        end

        local _name = text(name, "Type")
        local _icon = text(icon, "Label")

        new_line:append(_name)
        new_line:append(string.rep(" ", 18 - _name:width()))
        new_line:append(_icon)
        new_line:append(string.rep(" ", item_width - 18 - _icon:width()))

        count = count + 1
    end

    new_line:render(p.bufnr, -1, row)

    p:update_layout {
        size = {
            width = width,
            height = tostring(math.min(row, win_height - 2)),
        },
    }

    p:map("n", "q", function()
        local old_buf_list = vim.api.nvim_list_bufs()
        p:unmount()
        local new_buf_list = vim.api.nvim_list_bufs()
        for key, bufnr in pairs(new_buf_list) do
            if old_buf_list[key] ~= bufnr then
                vim.api.nvim_buf_delete(bufnr, { force = true })
                break
            end
        end
    end, { noremap = true, silent = true })

    vim.api.nvim_set_option_value("modifiable", false, { buf = p.bufnr })
    vim.api.nvim_set_option_value("readonly", true, { buf = p.bufnr })
end

-- Set up colorscheme and Ice.colorscheme, but does not take care of lualine
-- The colorscheme is a table with:
--   - name: to be called with the `colorscheme` command
--   - setup: optional; can either be:
--     - a function called alongside `colorscheme`
--     - a table for plugin setup
--   - background: "light" / "dark"
--   - lualine_theme: optional
---@param colorscheme_name string
utils.colorscheme = function(colorscheme_name)
    Ice.colorscheme = colorscheme_name

    local colorscheme = Ice.colorschemes[colorscheme_name]
    if not colorscheme then
        vim.notify(colorscheme_name .. " is not a valid color scheme!", vim.log.levels.ERROR)
        return
    end

    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

-- Switch colorscheme
utils.select_colorscheme = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    local function picker(opts)
        opts = opts or {}

        local colorschemes = Ice.colorschemes
        local suffix_current = " (current)"
        local results = { Ice.colorscheme .. suffix_current }
        for name, _ in require("core.utils").ordered_pair(colorschemes) do
            if name ~= Ice.colorscheme then
                results[#results + 1] = name
            end
        end

        pickers
            .new(opts, {
                prompt_title = "Colorschemes",
                finder = finders.new_table {
                    entry_maker = function(entry)
                        local pattern = string.gsub(suffix_current, "%(", "%%%(")
                        pattern = string.gsub(pattern, "%)", "%%%)")
                        local colorscheme, _ = string.gsub(entry, pattern, "")

                        return {
                            value = colorscheme,
                            display = entry,
                            ordinal = entry,
                        }
                    end,
                    results = results,
                },
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)

                        local selection = action_state.get_selected_entry()
                        local colorscheme = selection.value
                        local config = colorschemes[colorscheme]

                        if config.background == "light" then
                            ---@diagnostic disable-next-line: param-type-mismatch
                            pcall(vim.cmd, "TransparentDisable")
                        else
                            ---@diagnostic disable-next-line: param-type-mismatch
                            pcall(vim.cmd, "TransparentEnable")
                        end

                        utils.colorscheme(selection.value)

                        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
                        local f = io.open(colorscheme_cache, "w")
                        f:write(colorscheme)
                        f:close()
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

-- Quickly look through configuration files using telescope
utils.view_configuration = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local previewers = require "telescope.previewers.buffer_previewer"
    local from_entry = require "telescope.from_entry"

    local function picker(opts)
        opts = opts or {}

        local config_root = vim.fn.stdpath "config"
        local files = require("plenary.scandir").scan_dir(config_root, { hidden = true })
        local sep = require("plenary.path").path.sep
        local picker_sep = "/" -- sep that is displayed in the picker
        local results = {}

        local make_entry = require("telescope.make_entry").gen_from_file

        for _, item in pairs(files) do
            item = string.gsub(item, config_root, "")
            item = string.gsub(item, sep, picker_sep)
            item = string.sub(item, 2)
            if not (string.find(item, "bin/") or string.find(item, ".git/") or string.find(item, "screenshots/")) then
                results[#results + 1] = item
            end
        end

        pickers
            .new(opts, {
                prompt_title = "Configuration Files",
                finder = finders.new_table {
                    entry_maker = make_entry(opts),
                    results = results,
                },
                previewer = (function(_opts)
                    _opts = _opts or {}
                    return previewers.new_buffer_previewer {
                        title = "Configuration",
                        get_buffer_by_name = function(_, entry)
                            return from_entry.path(entry, false)
                        end,
                        define_preview = function(self, entry)
                            local p = config_root .. "/" .. entry.filename
                            if p == nil or p == "" then
                                return
                            end
                            conf.buffer_previewer_maker(p, self.state.bufnr, {
                                bufname = self.state.bufname,
                                winid = self.state.winid,
                                preview = _opts.preview,
                                file_encoding = _opts.file_encoding,
                            })
                        end,
                    }
                end)(opts),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)

                        local selection = action_state.get_selected_entry()[1]
                        selection = string.gsub(selection, picker_sep, sep)
                        local full_path = config_root .. sep .. selection

                        vim.cmd("edit " .. full_path)
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

return utils
