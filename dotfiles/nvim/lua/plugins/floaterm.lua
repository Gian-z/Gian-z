return {
    "voldikss/vim-floaterm",
    keys = {
        { "<leader>fn", "<Cmd>FloatermNew! --name=floaterm --height=0.8 --width=0.7 --autoclose=2<CR>", desc = "New Floaterm", silent = true, noremap = true },
        { "<leader>ff", "<Cmd>FloatermToggle floaterm<CR>", desc = "Toggle Floaterm", silent = true, noremap = true },
    }
}
