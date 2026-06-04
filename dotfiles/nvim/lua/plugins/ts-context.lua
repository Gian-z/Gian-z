return {
    "nvim-treesitter/nvim-treesitter-context",
    event = "User IceLoad",
    opts = {
        max_lines = 4,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "cursor",
        separator = "─",
    },
    keys = {
        { "<leader>uC", "<cmd>TSContextToggle<cr>", desc = "toggle treesitter context" },
    },
}
