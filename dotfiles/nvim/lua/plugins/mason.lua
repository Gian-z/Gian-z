return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    },
    event = "User IceLoad",
    cmd = "Mason",
    opts = {
        ui = {
            icons = {
                package_installed = Ice.symbols.Affirmative,
                package_pending = Ice.symbols.Pending,
                package_uninstalled = Ice.symbols.Negative,
            },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        local registry = require "mason-registry"
        local function install(package)
            local p = require("mason-registry").get_package(package)
            if not p:is_installed() then
                p:install()
            end
        end

        local mason_lspconfig_mapping = require("mason-lspconfig").get_mappings().package_to_lspconfig
        local installed_packages = registry.get_installed_package_names()

        for lsp, config in pairs(Ice.lsp) do
            install(lsp)

            local formatter = config.formatter
            if not formatter == nil then
                install(formatter)
            end

            if not vim.tbl_contains(installed_packages, lsp) then
                goto continue
            end

            lsp = mason_lspconfig_mapping[lsp]
            if not config.managed_by_plugin then
                local setup = config.setup
                if type(setup) == "function" then
                    setup = setup()
                elseif setup == nil then
                    setup = {}
                end

                local user_on_attach = function() end
                if type(setup.on_attach) == "function" then
                    user_on_attach = setup.on_attach
                end

                local on_attach = function(client, bufnr)
                    -- Only stop using lsp as format source if a formatter is set
                    if config.formatter ~= nil then
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end

                    require("core.utils").lsp_attach_keymap(bufnr)
                    user_on_attach(client, bufnr)
                end

                vim.lsp.config(lsp, {
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    on_attach = on_attach,
                })
                vim.lsp.enable(lsp)
            end
            ::continue::
        end

        -- UI
        vim.diagnostic.config {
            virtual_text = true,
            underline = true,
            update_in_insert = true,
            severity_sort = true,
            signs = {
                active = true,
                text = {
                    [vim.diagnostic.severity.ERROR] = Ice.symbols.Error,
                    [vim.diagnostic.severity.WARN] = Ice.symbols.Warn,
                    [vim.diagnostic.severity.HINT] = Ice.symbols.Hint,
                    [vim.diagnostic.severity.INFO] = Ice.symbols.Info,
                },
                numhl = {},
                linehl = {},
            },
            float = {
                border = "rounded",
                source = "always",
            },
        }

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover,
            { border = "rounded" }
        )

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            { border = "rounded" }
        )

        vim.api.nvim_command "LspStart"
    end,
}
