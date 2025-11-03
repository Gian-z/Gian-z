return {
    formatter = "csharpier",
    cmd = {
        "dotnet",
        vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/Omnisharp.dll",
    },
}
