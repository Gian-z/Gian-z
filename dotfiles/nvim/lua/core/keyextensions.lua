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

-- Side-panel filetypes that should keep their full height when the terminal
-- opens (the terminal then spans the main area beside them, not under them).
local SIDE_PANEL_FT = { "neo-tree", "aerial", "Outline", "undotree", "NvimTree" }

local function is_side_panel(win)
    return vim.tbl_contains(SIDE_PANEL_FT, vim.bo[vim.api.nvim_win_get_buf(win)].filetype)
end

-- Open a bottom window for the terminal and run `fill()` to populate it (start
-- a shell, or re-show the existing terminal buffer).
--
-- We always `botright split` for the full editor width, then push every side
-- panel back to a full-height side column with `wincmd H` / `L`. With no panel
-- that's simply a full-width split; with panels the layout becomes
-- `[panel | [main-windows / terminal]]`, so the terminal spans the whole main
-- area (across every main window) while the panels keep their full height.
local function open_terminal_window(fill)
    -- Record each side panel's side + width up front: the wincmd H/L reshuffle
    -- below re-equalizes window widths, so we restore them afterwards to stop
    -- the tree from visibly resizing when the terminal opens.
    local panels = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_side_panel(win) then
            panels[#panels + 1] = {
                win = win,
                width = vim.api.nvim_win_get_width(win),
                left = vim.api.nvim_win_get_position(win)[2] == 0,
            }
        end
    end

    vim.cmd "botright split"
    fill()
    local termwin = vim.api.nvim_get_current_win()

    -- Push each panel back to a full-height side column...
    for _, p in ipairs(panels) do
        if vim.api.nvim_win_is_valid(p.win) then
            vim.api.nvim_set_current_win(p.win)
            vim.cmd(p.left and "wincmd H" or "wincmd L")
        end
    end
    -- ...then restore its original width.
    for _, p in ipairs(panels) do
        if vim.api.nvim_win_is_valid(p.win) then
            vim.api.nvim_win_set_width(p.win, p.width)
        end
    end

    vim.api.nvim_set_current_win(termwin)
    vim.cmd "startinsert"
end

-- Launch the shell in the current window.
local function open_shell()
    if require("core.utils").is_windows() then
        vim.cmd "edit term://powershell"
    else
        vim.cmd "terminal" -- let $SHELL decide the default shell
    end
end

-- Tracks the single managed terminal buffer so <C-p> toggles its visibility
-- instead of spawning a new terminal on each invocation.
local terminal_bufnr = nil
-- When the terminal is maximised, this holds its dedicated full-screen tab.
local terminal_fullscreen_tab = nil

ret.toggle_terminal = function()
    if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
        local wins = vim.fn.win_findbuf(terminal_bufnr)
        if #wins > 0 then
            for _, win in ipairs(wins) do
                vim.api.nvim_win_hide(win)
            end
            return
        end
        open_terminal_window(function()
            vim.api.nvim_win_set_buf(0, terminal_bufnr)
        end)
        return
    end

    open_terminal_window(function()
        open_shell()
        terminal_bufnr = vim.api.nvim_get_current_buf()
    end)
end

-- Toggle the managed terminal between its bottom split and a dedicated
-- full-screen tab. Going fullscreen hides the split and shows the terminal
-- alone in its own tab; toggling back closes that tab and restores the split.
ret.toggle_terminal_fullscreen = function()
    -- Already fullscreen -> close the tab and restore the bottom split.
    if terminal_fullscreen_tab and vim.api.nvim_tabpage_is_valid(terminal_fullscreen_tab) then
        local tab = terminal_fullscreen_tab
        terminal_fullscreen_tab = nil
        if #vim.api.nvim_list_tabpages() > 1 then
            vim.api.nvim_set_current_tabpage(tab)
            vim.cmd "tabclose"
        end
        if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
            open_terminal_window(function()
                vim.api.nvim_win_set_buf(0, terminal_bufnr)
            end)
        end
        return
    end

    -- Going fullscreen: reuse the existing terminal if there is one, hiding it
    -- wherever it currently sits, otherwise spawn a fresh one in the new tab.
    local have_terminal = terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr)
    if have_terminal then
        for _, win in ipairs(vim.fn.win_findbuf(terminal_bufnr)) do
            vim.api.nvim_win_hide(win)
        end
    end

    vim.cmd "tabnew"
    if have_terminal then
        local scratch = vim.api.nvim_get_current_buf()
        vim.api.nvim_win_set_buf(0, terminal_bufnr)
        if scratch ~= terminal_bufnr and vim.api.nvim_buf_is_valid(scratch) then
            pcall(vim.api.nvim_buf_delete, scratch, { force = true })
        end
    else
        open_shell()
        terminal_bufnr = vim.api.nvim_get_current_buf()
    end

    terminal_fullscreen_tab = vim.api.nvim_get_current_tabpage()
    vim.cmd "startinsert"
end

-- MRU (most-recently-used) buffer cycling, Alt-Tab style.
--
-- This and the Telescope picker (<leader>bb) share a single source of truth:
-- Vim's own `lastused` timestamp per buffer (exactly what Telescope's
-- `sort_mru` reads). There is no separate list to maintain or keep in sync.
--
-- We snapshot that order when a cycle "session" starts and freeze it for the
-- session's duration. The freeze is essential: every buffer switch bumps the
-- visited buffer's `lastused`, so re-reading it each tap would collapse the
-- cycle into a two-buffer ping-pong. An inactivity timer ends the session; the
-- next press re-reads `lastused`, which by then reflects wherever we landed.
local snapshot = nil -- frozen bufnr list during a session, nil between sessions
local cycle_index = 1 -- 1-based position within `snapshot`
local cycle_timer = nil -- uv timer that ends the session after inactivity
local CYCLE_TIMEOUT = 1500 -- ms of inactivity before a session ends

-- True only for normal, listed file buffers. Excludes terminals, help,
-- quickfix and plugin scratch buffers (oil, neo-tree, dashboard, …), which all
-- carry a non-empty 'buftype', so they never enter the <Tab> cycle.
local function is_file_buffer(bufnr)
    return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == ""
end

-- File buffers in most-recently-used order (newest first), read from Vim's
-- `lastused`. This is the exact ranking Telescope's `sort_mru` uses.
local function mru_buffers()
    local infos = vim.fn.getbufinfo { buflisted = 1 }
    table.sort(infos, function(a, b)
        return a.lastused > b.lastused
    end)
    local bufs = {}
    for _, info in ipairs(infos) do
        if is_file_buffer(info.bufnr) then
            bufs[#bufs + 1] = info.bufnr
        end
    end
    return bufs
end

local function end_session()
    snapshot = nil
    cycle_index = 1
    if cycle_timer then
        cycle_timer:stop()
    end
end

local function restart_timer()
    if not cycle_timer then
        cycle_timer = vim.uv.new_timer()
    end
    cycle_timer:stop()
    cycle_timer:start(CYCLE_TIMEOUT, 0, vim.schedule_wrap(end_session))
end

local function cycle(step)
    if not snapshot then
        snapshot = mru_buffers() -- snapshot[1] is the current buffer
        cycle_index = 1
    else
        -- drop buffers closed (or turned non-file) since the session began
        local kept = {}
        for _, b in ipairs(snapshot) do
            if is_file_buffer(b) then
                kept[#kept + 1] = b
            end
        end
        snapshot = kept
    end

    if #snapshot < 2 then
        return
    end

    cycle_index = ((cycle_index - 1 + step) % #snapshot) + 1
    local target = snapshot[cycle_index]
    if vim.api.nvim_buf_is_valid(target) then
        vim.api.nvim_set_current_buf(target)
    end
    restart_timer()
end

ret.cycle_buffer_next = function()
    cycle(1)
end
ret.cycle_buffer_prev = function()
    cycle(-1)
end

-- Build the CMI MetaTool solution in a terminal split. Paths are specific to
-- the developer's machine, so the action no-ops with a warning when MSBuild or
-- the solution is missing instead of opening a terminal that immediately errors.
ret.build_metatool = function()
    local msbuild = "c:/CMI-GitHub/SDK/VsBuildTools/MSBuild/Current/Bin/amd64/MSBuild.exe"
    local solution = "c:/CMI-GitHub/cmi-metatool/server/src/MetaTool.sln"
    return function()
        if vim.fn.executable(msbuild) ~= 1 then
            vim.notify("MetaTool build: MSBuild not found at " .. msbuild, vim.log.levels.WARN)
            return
        end
        if vim.fn.filereadable(solution) ~= 1 then
            vim.notify("MetaTool build: solution not found at " .. solution, vim.log.levels.WARN)
            return
        end
        open_terminal_window(function()
            vim.cmd("edit term://powershell " .. msbuild .. " /m " .. solution .. " /t:Build")
        end)
    end
end

return ret
