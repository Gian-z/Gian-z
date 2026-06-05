return {
    "lewis6991/gitsigns.nvim",
    event = "User IceLoad",
    main = "gitsigns",
    opts = {},
    keys = {
        { "<leader>gn", "<Cmd>Gitsigns next_hunk<CR>", desc = "next hunk", silent = true, noremap = true },
        { "<leader>gp", "<Cmd>Gitsigns prev_hunk<CR>", desc = "prev hunk", silent = true, noremap = true },
        { "<leader>gP", "<Cmd>Gitsigns preview_hunk<CR>", desc = "preview hunk", silent = true, noremap = true },
        { "<leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", desc = "stage / unstage hunk", silent = true, noremap = true },
        { "<leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", desc = "reset hunk", silent = true, noremap = true },
        { "<leader>gB", "<Cmd>Gitsigns stage_buffer<CR>", desc = "stage buffer", silent = true, noremap = true },
        {
            "<leader>gb",
            -- Toggle the full-file blame window: close it if it's already open
            -- (its buffer filetype is "gitsigns-blame"), otherwise open it.
            function()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "gitsigns-blame" then
                        vim.api.nvim_win_close(win, false)
                        return
                    end
                end
                vim.cmd "Gitsigns blame"
            end,
            desc = "toggle git blame",
            silent = true,
            noremap = true,
        },
        { "<leader>gl", "<Cmd>Gitsigns blame_line<CR>", desc = "git blame line", silent = true, noremap = true },
        {
            "<leader>gt",
            "<Cmd>Gitsigns toggle_current_line_blame<CR>",
            desc = "git toggle blame line",
            silent = true,
            noremap = true,
        },
    },
}
