return {
    "karb94/neoscroll.nvim",
    main = "neoscroll",
    opts = {
        mappings = {},
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "sine",
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
    },
    keys = {
        {
            "<C-u>",
            function()
                require("neoscroll").scroll(-vim.wo.scroll, true, 250)
            end,
            desc = "scroll up",
        },
        {
            "<C-d>",
            function()
                require("neoscroll").scroll(vim.wo.scroll, true, 250)
            end,
            desc = "scroll down",
        },
    },
}