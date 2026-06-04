-- Diagnostic and LSP handler UI. Loaded once at startup; relies on Ice.symbols.
-- Hover / signature-help borders inherit from `vim.o.winborder` (set in core.basic).
vim.diagnostic.config {
    virtual_text = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    signs = {
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
        source = true,
    },
}
