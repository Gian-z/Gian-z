return {
    "mfussenegger/nvim-lint",
    -- Don't lazy on BufReadPost/BufNewFile: lazy.nvim's handler runs in the
    -- same autocmd chain and trips `did_filetype`, so Neovim's filetypedetect
    -- `:setf` becomes a no-op and FileType never fires (no treesitter, no LSP).
    -- See `:h :setfiletype`. IceLoad fires on first real BufEnter, which is
    -- early enough for this plugin's own BufReadPost autocmd to take over.
    event = "User IceLoad",
    keys = {
        {
            "<leader>ll",
            function()
                require("lint").try_lint()
            end,
            mode = "n",
            desc = "lint buffer",
        },
    },
    config = function()
        local lint = require "lint"
        lint.linters_by_ft = {
            markdown = { "markdownlint" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            yaml = { "yamllint" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
        }

        -- Best-effort install via mason of every linter referenced above;
        -- silently skip if mason isn't ready or a package name has drifted in
        -- the registry. Derived from linters_by_ft so the two never diverge.
        local ok_registry, registry = pcall(require, "mason-registry")
        if ok_registry then
            local seen = {}
            for _, linters in pairs(lint.linters_by_ft) do
                for _, name in ipairs(linters) do
                    if not seen[name] then
                        seen[name] = true
                        local ok_pkg, pkg = pcall(registry.get_package, name)
                        if ok_pkg and not pkg:is_installed() then
                            pkg:install()
                        end
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
