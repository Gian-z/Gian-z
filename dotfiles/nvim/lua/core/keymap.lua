local ext = require "core.keyextensions"
local utils = require "core.utils"
local pickers = require "core.pickers"

vim.g.mapleader = ";"
vim.g.maplocalleader = ","

Ice.keymap = {}
Ice.keymap.lsp = {}
Ice.keymap.prefix = {
    { "<leader>a", group = "+ai" },
    { "<leader>b", group = "+buffer" },
    { "<leader>c", group = "+comment" },
    { "<leader>d", group = "+debug" },
    { "<leader>g", group = "+git" },
    { "<leader>l", group = "+lsp" },
    { "<leader>m", group = "+harpoon" },
    { "<leader>n", group = "+test" },
    { "<leader>q", group = "+session" },
    { "<leader>u", group = "+utils" },
    { "<leader>w", group = "+window" },
    { "gr", group = "+lsp" },
}

Ice.keymap.general = {
    -- See `:h quote_`
    black_hole_register = { { "n", "v" }, "\\", '"_' },
    clear_cmd_line = { "n", "<C-g>", "<Cmd>mode<CR>", { noremap = true } },

    -- Cycle most-recently-used buffers (Alt-Tab style); see core.keyextensions
    cycle_buffer_next = { "n", "<Tab>", ext.cycle_buffer_next },
    cycle_buffer_prev = { "n", "<S-Tab>", ext.cycle_buffer_prev },

    join_lines = { { "n", "v" }, "J", ext.join_lines },

    -- Move the cursor through wrapped lines with j and k
    -- https://github.com/NvChad/NvChad/blob/b9963e29b21a672325af5b51f1d32a9191abcdaa/lua/core/mappings.lua#L40C5-L41C99
    move_down = { "n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true } },
    move_up = { "n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true } },

    new_line_below_normal = { "n", "<A-o>", "o<Esc>" },
    new_line_above_normal = { "n", "<A-O>", "O<Esc>" },
    new_line_below_insert = { "i", "<A-o>", "<Esc>o" },
    new_line_above_insert = { "i", "<A-O>", "<Esc>O" },

    open_html_file = { "n", "<A-b>", ext.open_html_file },
    toggle_terminal = { { "n", "t" }, "<C-p>", ext.toggle_terminal },
    terminal_fullscreen = { "t", "<C-f>", ext.toggle_terminal_fullscreen },
    fullscreen_terminal = { "n", "<Leader>wf", ext.toggle_terminal_fullscreen },
    normal_mode_in_terminal = { "t", "<Esc><Esc>", "<C-\\><C-n>" },
    save_file = { { "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>" },

    shift_line_left = { "v", "<", "<gv" },
    shift_line_right = { "v", ">", ">gv" },

    undo = { { "n", "i", "v" }, "<C-z>", ext.undo },

    window_left = { { "n", "t" }, "<C-h>", "<Cmd>wincmd h<CR>" },
    window_right = { { "n", "t" }, "<C-l>", "<Cmd>wincmd l<CR>" },
    window_up = { { "n", "t" }, "<C-k>", "<Cmd>wincmd k<CR>" },
    window_down = { { "n", "t" }, "<C-j>", "<Cmd>wincmd j<CR>" },

    window_new = { "n", "<Leader>wn", "<Cmd>new<CR>" },
    window_new_v = { "n", "<Leader>wvn", "<Cmd>vnew<CR>" },

    cmi_metatool_build = { "n", "<Leader>mb", ext.build_metatool() },
}

Ice.keymap.lsp.mapLsp = {
    -- LSP navigation & actions follow Neovim's built-in gr* convention
    -- (gd / grr / gri / grn / gra / gO); go-to lookups are Telescope-backed.
    go_to_definition = { "n", "gd", "<Cmd>Telescope lsp_definitions<CR>" },
    go_to_type_definition = { "n", "gy", "<Cmd>Telescope lsp_type_definitions<CR>" },
    go_to_implementation = { "n", "gri", "<Cmd>Telescope lsp_implementations<CR>" },
    find_references = { "n", "grr", "<Cmd>Telescope lsp_references<CR>" },
    rename_symbol = { "n", "grn", vim.lsp.buf.rename },
    code_action = { { "n", "v" }, "gra", vim.lsp.buf.code_action },
    document_symbols = { "n", "gO", "<Cmd>Telescope lsp_document_symbols<CR>" },
    workspace_symbols = { "n", "<leader>lS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>" },

    hover_doc = { "n", "K", vim.lsp.buf.hover },
    signature_help = { "i", "<C-/>", vim.lsp.buf.signature_help },

    show_line_diagnostic = { "n", "<leader>lc", vim.diagnostic.open_float },
    next_diagnostic = {
        "n",
        "<leader>lj",
        function()
            vim.diagnostic.jump { count = 1, float = true }
        end,
    },
    prev_diagnostic = {
        "n",
        "<leader>lk",
        function()
            vim.diagnostic.jump { count = -1, float = true }
        end,
    },
    -- <leader>lt (Trouble) is provided globally by the trouble.nvim lazy-key.
}

Ice.keymap.plugins = {
    recent_buffers = { "n", "<leader>bb", pickers.recent_buffers },
    check_icons = { "n", "<leader>ui", pickers.check_icons },
    lazy_profile = {
        "n",
        "<leader>ul",
        "<Cmd>Lazy profile<CR>",
    },
    select_colorscheme = { "n", "<leader>uk", pickers.select_colorscheme },
    view_configuration = { "n", "<leader>uc", pickers.view_configuration },
}
