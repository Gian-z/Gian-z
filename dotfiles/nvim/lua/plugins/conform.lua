-- Formatter runner (replaces null-ls)
return {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "User IceLoad" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>lf",
            function()
                require("conform").format { async = true, lsp_format = "fallback" }
            end,
            mode = { "n", "v" },
            desc = "format code",
        },
    },
    opts = {
        -- Single source of truth for formatters: this map drives both what runs
        -- on <leader>lf and what gets installed via mason (see config below).
        -- Mason package names must match the formatter names used here.
        formatters_by_ft = {
            lua = { "stylua" },
            typst = { "typstyle" },
            cs = { "csharpier" },
            go = { "gofumpt" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            less = { "prettier" },
            sh = { "shfmt" },
            bash = { "shfmt" },
        },
        default_format_opts = { lsp_format = "fallback" },
    },
    config = function(_, opts)
        require("conform").setup(opts)

        -- Best-effort install of every formatter via mason; silently skips if
        -- mason isn't ready yet (picked up next session). Mirrors nvim-lint.
        local ok_registry, registry = pcall(require, "mason-registry")
        if not ok_registry then
            return
        end
        local seen = {}
        for _, formatters in pairs(opts.formatters_by_ft) do
            for _, name in ipairs(formatters) do
                if not seen[name] then
                    seen[name] = true
                    local ok_pkg, pkg = pcall(registry.get_package, name)
                    if ok_pkg and not pkg:is_installed() then
                        pkg:install()
                    end
                end
            end
        end
    end,
}
