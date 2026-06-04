-- Completion (replaces nvim-cmp)
return {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
        { "L3MON4D3/LuaSnip", version = "v2.*" },
        "rafamadriz/friendly-snippets",
    },
    event = { "InsertEnter", "CmdlineEnter", "User IceLoad" },
    opts = {
        keymap = {
            preset = "default",
            ["<A-c>"] = { "show", "hide", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<Tab>"] = { "accept", "fallback" },
            ["<Up>"] = { "scroll_documentation_up", "fallback" },
            ["<Down>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
            menu = { border = "rounded" },
            list = { selection = { preselect = true, auto_insert = false } },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
        snippets = { preset = "luasnip" },
        cmdline = {
            keymap = {
                ["<Tab>"] = { "accept", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },
            completion = { menu = { auto_show = true } },
        },
        signature = { enabled = true, window = { border = "rounded" } },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
        require("luasnip.loaders.from_vscode").lazy_load { paths = vim.fn.stdpath "data" .. "/lazy/friendly-snippets" }
    end,
}
