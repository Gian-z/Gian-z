return {
    "simrat39/rust-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "rust",
    main = "rust-tools",
    opts = {
        server = {
            on_attach = function(_, bufnr)
                require("core.utils").lsp_attach_keymap(bufnr)
            end,
        },
    },
}
