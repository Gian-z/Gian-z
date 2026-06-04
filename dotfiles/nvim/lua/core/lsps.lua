-- LSP registry. Fields per entry:
--   active            - install + enable this server
--   managed_by_plugin - a plugin starts the client (roslyn, rust); skip generic setup
--   formatter         - marks the server as formatted by an external tool, so its
--                       own LSP formatting is disabled. The formatter itself (which
--                       tool, and its installation) is defined in plugins/conform.lua,
--                       the single source of truth; the value here is informational.
local config = {}

config.tinymist = { active = true, formatter = "typstyle" }
config.roslyn = { active = true, managed_by_plugin = true, formatter = "csharpier" }
config.clangd = { active = true }
config.gopls = { active = false, formatter = "gofumpt" }
config.rust = { active = false, managed_by_plugin = true }
config["yaml-language-server"] = { active = true }
config["typescript-language-server"] = { active = true, formatter = "prettier" }
config["html-lsp"] = { active = true, formatter = "prettier" }
config["json-lsp"] = { active = true, formatter = "prettier" }
config["css-lsp"] = { active = true, formatter = "prettier" }
config["emmet-ls"] = { active = false }
config["bash-language-server"] = { active = true, formatter = "shfmt" }
config["lua-language-server"] = { active = true, formatter = "stylua" }

Ice.lsp = config
