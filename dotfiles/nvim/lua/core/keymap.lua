local ext = require("core.keyextensions")

vim.g.mapleader = " "
vim.g.maplocalleader = ","

Ice.keymap = {}
Ice.keymap.general = {
    -- See `:h quote_`
    black_hole_register = { { "n", "v" }, "\\", '"_' },
    clear_cmd_line = { { "n", "i", "v", "t" }, "<C-g>", "<Cmd>mode<CR>", { noremap = true } },
    cmd_forward = { "c", "<C-f>", "<Right>", { silent = false } },
    cmd_backward = { "c", "<C-b>", "<Left>", { silent = false } },
    cmd_home = { "c", "<C-a>", "<Home>", { silent = false } },
    cmd_end = { "c", "<C-e>", "<End>", { silent = false } },
    cmd_word_forward = { "c", "<A-f>", "<S-Right>", { silent = false } },
    cmd_word_backward = { "c", "<A-b>", "<S-Left>", { silent = false } },

   join_lines = {
        { "n", "v" },
        "J",
        function()
            local v_count = vim.v.count1 + 1
            local mode = vim.api.nvim_get_mode().mode
            local keys
            if mode == "n" then
                keys = v_count .. "J"
            else
                keys = "J"
            end
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
        end,
    },

    -- Move the cursor through wrapped lines with j and k
    -- https://github.com/NvChad/NvChad/blob/b9963e29b21a672325af5b51f1d32a9191abcdaa/lua/core/mappings.lua#L40C5-L41C99
    move_down = { "n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true } },
    move_up = { "n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true } },

    new_line_below_normal = {
        "n",
        "<A-o>",
        "o<Esc>",
    },
    new_line_above_normal = {
        "n",
        "<A-O>",
        "O<Esc>",
    },
    new_line_below_insert = {
        "i",
        "<A-o>",
        "<Esc>o",
    },
    new_line_above_insert = {
        "i",
        "<A-O>",
        "<Esc>O",
    },

    open_html_file = { "n", "<A-b>", ext.open_html_file },
    open_terminal = { "n", "<C-t>", ext.terminal_command },
    normal_mode_in_terminal = { "t", "<Esc>", "<C-\\><C-n>" },
    save_file = { { "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>" },
    shift_line_left = { "v", "<", "<gv" },
    shift_line_right = { "v", ">", ">gv" },
    undo = { { "n", "i", "v", "t", "c" }, "<C-z>", ext.undo },
    visual_line = { "n", "V", "0v$" },
    floaterm_toggle = { "t", "<Esc>", "<Cmd>FloatermToggle floaterm<CR>"}
}
