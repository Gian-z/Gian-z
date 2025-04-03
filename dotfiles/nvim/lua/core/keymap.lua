local ext = require "core.keyextensions"

vim.g.mapleader = ";"
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
    cmd_word_forward = { "c", "<a-f>", "<s-right>", { silent = false } },
    cmd_word_backward = { "c", "<A-b>", "<S-Left>", { silent = false } },

    join_lines = { { "n", "v" }, "J", ext.join_lines },

    -- Move the cursor through wrapped lines with j and k
    -- https://github.com/NvChad/NvChad/blob/b9963e29b21a672325af5b51f1d32a9191abcdaa/lua/core/mappings.lua#L40C5-L41C99
    move_down = { "n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true } },
    move_up = { "n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true } },

    new_line_below_normal = { "n", "<A-o>", "o<Esc>", },
    new_line_above_normal = { "n", "<A-O>", "O<Esc>", },
    new_line_below_insert = { "i", "<A-o>", "<Esc>o", },
    new_line_above_insert = { "i", "<A-O>", "<Esc>O", },

    open_html_file = { "n", "<A-b>", ext.open_html_file },
    open_terminal = { "n", "<C-t>", ext.get_terminalcmd() }, -- Not passed as function because it returns the actual command
    normal_mode_in_terminal = { "t", "<Esc>", "<C-\\><C-n>" },
    save_file = { { "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>" },
    shift_line_left = { "v", "<", "<gv" },
    shift_line_right = { "v", ">", ">gv" },
    undo = { { "n", "i", "v", "t", "c" }, "<C-z>", ext.undo },
    visual_line = { "n", "V", "0v$" },

    window_left = { { "n", "i", "v", "t", "c" }, "<C-h>", "<Cmd>wincmd h<CR>" },
    window_right = { { "n", "i", "v", "t", "c" }, "<C-l>", "<Cmd>wincmd l<CR>" },
    window_up = { { "n", "i", "v", "t", "c" }, "<C-k>", "<Cmd>wincmd k<CR>" },
    window_down = { { "n", "i", "v", "t", "c" }, "<C-j>", "<Cmd>wincmd j<CR>" },
    window_new = { { "n", "i", "v", "t", "c" }, "<Leader>wn", "<Cmd>new<CR>" },
    window_new_v = { { "n", "i", "v", "t", "c" }, "<Leader>wvn", "<Cmd>vnew<CR>" },

    cmi_metatool_build = {"n", "<Leader>mb", ext.build_metatool()},
}
