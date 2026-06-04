-- Selected mini.nvim modules
return {
    "nvim-mini/mini.nvim",
    version = false,
    event = "User IceLoad",
    config = function()
        require("mini.ai").setup {}
        require("mini.move").setup {
            mappings = {
                left = "<M-h>",
                right = "<M-l>",
                down = "<M-j>",
                up = "<M-k>",
                line_left = "<M-h>",
                line_right = "<M-l>",
                line_down = "<M-j>",
                line_up = "<M-k>",
            },
        }
    end,
}
