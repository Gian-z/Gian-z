-- Microsoft Roslyn language server for C#. Replaces OmniSharp; doesn't
-- lock NuGet package files, so `dotnet restore`/`build` work while attached.
-- Reads the Roslyn LS binary from Mason (package: `roslyn`).
return {
    "seblyng/roslyn.nvim",
    ft = "cs",
    -- Registered in `init` (runs at startup) rather than `config` (runs after
    -- the plugin loads). roslyn.nvim's plugin/roslyn.lua calls
    -- `vim.lsp.enable("roslyn")` on load, which starts the client immediately;
    -- if we set on_attach in `config`, it arrives too late and the buffer-local
    -- LSP keymaps (e.g. <leader>la) are never bound.
    init = function()
        vim.lsp.config("roslyn", {
            on_attach = function(_, bufnr)
                require("core.utils").lsp_attach_keymap(bufnr)
            end,
            settings = {
                ["csharp|inlay_hints"] = {
                    csharp_enable_inlay_hints_for_implicit_object_creation = true,
                    csharp_enable_inlay_hints_for_implicit_variable_types = true,
                    csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                    dotnet_enable_inlay_hints_for_parameters = true,
                },
                ["csharp|code_lens"] = {
                    dotnet_enable_references_code_lens = true,
                },
                ["csharp|background_analysis"] = {
                    dotnet_compiler_diagnostics_scope = "fullSolution",
                    dotnet_analyzer_diagnostics_scope = "fullSolution",
                },
            },
        })
    end,
}
