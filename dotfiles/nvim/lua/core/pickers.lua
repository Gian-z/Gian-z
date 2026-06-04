-- Telescope-backed pickers. Each function bails out silently if telescope is
-- not yet loaded.

local M = {}

-- Switch colorscheme via a Telescope picker.
M.select_colorscheme = function()
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

                        require("core.utils").colorscheme(selection.value)

                        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
                        local f = io.open(colorscheme_cache, "w")
                        ---@diagnostic disable-next-line: need-check-nil
                        f:write(colorscheme)
                        ---@diagnostic disable-next-line: need-check-nil
                        f:close()
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

-- Quickly look through configuration files using telescope.
M.view_configuration = function()
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
        local picker_sep = "/"
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

-- Pick a buffer in most-recently-used order, mirroring the <Tab> cycle.
-- Telescope's builtin buffers picker can't filter by buftype, so we build the
-- buffer list ourselves — file buffers only (buftype ""), newest-first by
-- `lastused`, current buffer excluded — then hand it to Telescope's own entry
-- maker / previewer for preview, devicons and <M-d> delete. This keeps the
-- picker and the <Tab> cycle (core.keyextensions) on the same set of buffers.
M.recent_buffers = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local make_entry = require "telescope.make_entry"
    local actions = require "telescope.actions"

    local current = vim.api.nvim_get_current_buf()
    local bufnrs = vim.tbl_filter(function(bufnr)
        return vim.api.nvim_buf_is_valid(bufnr)
            and vim.bo[bufnr].buflisted
            and vim.bo[bufnr].buftype == ""
            and bufnr ~= current
    end, vim.api.nvim_list_bufs())

    if not next(bufnrs) then
        return
    end

    table.sort(bufnrs, function(a, b)
        return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
    end)

    local buffers = {}
    for _, bufnr in ipairs(bufnrs) do
        local flag = bufnr == vim.fn.bufnr "" and "%" or (bufnr == vim.fn.bufnr "#" and "#" or " ")
        buffers[#buffers + 1] = {
            bufnr = bufnr,
            flag = flag,
            info = vim.fn.getbufinfo(bufnr)[1],
        }
    end

    -- path_display ("filename_first") is inherited from telescope defaults.
    local opts = { bufnr_width = #tostring(math.max(unpack(bufnrs))) }

    pickers
        .new(opts, {
            prompt_title = "Recent Buffers",
            finder = finders.new_table {
                results = buffers,
                entry_maker = make_entry.gen_from_buffer(opts),
            },
            previewer = conf.grep_previewer(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(_, map)
                map({ "i", "n" }, "<M-d>", actions.delete_buffer)
                return true
            end,
        })
        :find()
end

-- Show all configured Nerd Font symbols in a nui popup.
M.check_icons = function()
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

return M
