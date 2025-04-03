Ice.keymap.lsp = {}

Ice.keymap.lsp.mapLsp = {
    rename = { "n", "<leader>lr", "<Cmd>Lspsaga rename<CR>" },
    code_action = { "n", "<leader>ca", "<Cmd>Lspsaga code_action<CR>" },

    hover_doc = { "n", "K", require("core.keyextensions").get_hoverdoc },
    go_to_definition = { "n", "gd", "<Cmd>Lspsaga goto_definition<CR>" },
    go_to_references = { "n", "gr", "<Cmd>Lspsaga finder<CR>" },

    show_line_diagnostic = { "n", "<leader>lc", "<Cmd>Lspsaga show_line_diagnostics<CR>" },
    next_diagnostic = { "n", "<leader>ln", "<Cmd>Lspsaga diagnostic_jump_next<CR>" },
    prev_diagnostic = { "n", "<leader>lp", "<Cmd>Lspsaga diagnostic_jump_prev<CR>" },
}

Ice.keymap.lsp.cmp = {
    toggle_completion = "<A-c>",
    prev_item = "<C-k>",
    next_item = "<C-j>",
    confirm = "<Tab>",
    doc_up = "<Up>",
    doc_down = "<Down>",
}
