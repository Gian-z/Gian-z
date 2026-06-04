return {
    "gbprod/yanky.nvim",
    event = "User IceLoad",
    opts = {
        ring = {
            history_length = 100,
            sync_with_numbered_registers = true,
        },
        system_clipboard = {
            sync_with_ring = true,
        },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 200,
        },
    },
    keys = {
        { "<Leader>uy", "<Cmd>YankyRingHistory<CR>", desc = "yank history" },
        { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "yank" },
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "put after" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "put before" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "put after (cursor after)" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "put before (cursor after)" },
        { "[y", "<Plug>(YankyCycleBackward)", desc = "cycle backward through yank history" },
        { "]y", "<Plug>(YankyCycleForward)", desc = "cycle forward through yank history" },
    },
}
