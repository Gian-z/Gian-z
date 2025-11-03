local config = {}

config["lua-language-server"] = {
    formatter = "stylua",
}

config.tinymist = {
    formatter = "typstfmt",
}

config.omnisharp = {
    formatter = "csharpier"
}

Ice.lsp = config
