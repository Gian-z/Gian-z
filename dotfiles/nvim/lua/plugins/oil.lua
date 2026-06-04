return {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    opts = {
        default_file_explorer = true,
        view_options = { show_hidden = true },
    },
    keys = {
        { "-", "<cmd>Oil<cr>", desc = "open parent directory (oil)" },
        { "_", "<cmd>Oil .<cr>", desc = "open cwd (oil)" },
        { "<leader>o", "<cmd>Oil<cr>", desc = "open oil" },
    },
}
