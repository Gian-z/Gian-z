return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    keys = {
        { "<leader>uo", "<cmd>AerialToggle!<cr>", desc = "outline toggle" },
        { "<leader>uO", "<cmd>AerialNavToggle<cr>", desc = "outline nav" },
    },
    opts = {
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
            min_width = 30,
            default_direction = "right",
        },
        attach_mode = "global",
        filter_kind = false,
        show_guides = true,
        autojump = true,
        on_attach = function(bufnr)
            vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "prev symbol" })
            vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "next symbol" })
        end,
    },
}
