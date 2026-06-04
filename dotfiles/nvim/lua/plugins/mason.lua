return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    },
    event = "User IceLoad",
    cmd = "Mason",
    opts = {
        registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
        },
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
            local p = registry.get_package(package)
            if not p:is_installed() then
                p:install()
            end
        end

        local mason_lspconfig_mapping = require("mason-lspconfig").get_mappings().package_to_lspconfig
        local installed_packages = registry.get_installed_package_names()

        local ok_blink, blink = pcall(require, "blink.cmp")
        local capabilities = ok_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

        for lsp, config in pairs(Ice.lsp) do
            if config.active then
                install(lsp)

                -- Plugin-managed servers (roslyn, rust) start their own client,
                -- so skip them here. Also skip on the very first run, before the
                -- mason package has finished installing — it's picked up next
                -- session. Per-server settings live in the native
                -- `lsp/<name>.lua` files, which vim.lsp.config() merges in.
                if not config.managed_by_plugin and vim.tbl_contains(installed_packages, lsp) then
                    local formatter = config.formatter
                    local on_attach = function(client, bufnr)
                        -- Defer formatting to conform when a formatter is set, so
                        -- the LSP isn't also offered as a formatting source.
                        if formatter ~= nil then
                            client.server_capabilities.documentFormattingProvider = false
                            client.server_capabilities.documentRangeFormattingProvider = false
                        end
                        require("core.utils").lsp_attach_keymap(bufnr)
                    end

                    local server = mason_lspconfig_mapping[lsp]
                    vim.lsp.config(server, {
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                    vim.lsp.enable(server)
                end
            end
        end

        -- vim.lsp.enable() only attaches on the next FileType event. For buffers
        -- already loaded when mason's config runs (the one that triggered
        -- `User IceLoad`), re-fire FileType so the just-enabled servers attach.
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "" then
                vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })
            end
        end
    end,
}
