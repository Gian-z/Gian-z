return {
    formatter = "prettier",
    single_file_support = true,
    flags = lsp.flags,
    on_attach = function(client)
        if #vim.lsp.get_clients { name = "denols" } > 0 then
            client.stop()
        end
    end,
}
