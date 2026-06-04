return {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    main = "neogit",
    opts = {
        disable_hint = true,
        status = {
            recent_commit_count = 30,
        },
        commit_editor = {
            kind = "auto",
            show_staged_diff = false,
        },
    },
    keys = {
        { "<leader>go", "<Cmd>Neogit<CR>", desc = "neogit", silent = true },
    },
    config = function(_, opts)
        require("neogit").setup(opts)
        -- Place the cursor at the top of the commit message buffer. Registered
        -- directly as a FileType autocmd: neogit's config runs lazily, after the
        -- startup loop that turns Ice.ft entries into autocmds has already run.
        require("core.utils").ft("NeogitCommitMessage", function()
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end)
    end,
}
