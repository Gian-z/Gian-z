return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewFileHistory",
        "DiffviewRefresh",
    },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "diff view open" },
        { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "diff view close" },
        { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "branch file history" },
        { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "current file history" },
    },
    opts = {
        enhanced_diff_hl = true,
        view = {
            merge_tool = { layout = "diff3_mixed" },
        },
    },
}
