-- Harpoon, driven through the mark keys: m1-m4 jump to pinned files, ma adds
-- the current file, me opens the editable menu. Native marks still work for
-- every other letter (only m + a / e / 1-4 are taken).
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("harpoon"):setup()
    end,
    keys = {
        {
            "ma",
            function()
                require("harpoon"):list():add()
            end,
            desc = "harpoon add file",
        },
        {
            "me",
            function()
                local harpoon = require "harpoon"
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "harpoon menu",
        },
        {
            "m1",
            function()
                require("harpoon"):list():select(1)
            end,
            desc = "harpoon file 1",
        },
        {
            "m2",
            function()
                require("harpoon"):list():select(2)
            end,
            desc = "harpoon file 2",
        },
        {
            "m3",
            function()
                require("harpoon"):list():select(3)
            end,
            desc = "harpoon file 3",
        },
        {
            "m4",
            function()
                require("harpoon"):list():select(4)
            end,
            desc = "harpoon file 4",
        },
    },
}
