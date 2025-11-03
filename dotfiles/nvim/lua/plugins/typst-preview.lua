return {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
        require("typst-preview").update()
    end,
    opts = {},
    keys = {
        {
            "<A-b>",
            "<Cmd>TypstPreviewToggle<CR>",
            desc = "typst preview toggle",
            ft = "typst",
            silent = true,
            noremap = true,
        },
    },
}
