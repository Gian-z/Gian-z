local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = nvlsp.on_attach
local on_init = nvlsp.on_init
local capabilities = nvlsp.capabilities

local servers = { "html", "cssls", "tsserver" }
local masonPath = os.getenv "HOME" .. "/AppData/Local/nvim-data/mason/bin"

-- require("customlsp.bdd").setup {
--   cmd = { "C:/Users/GZW/AppData/Local/nvim/lua/customlsp/bdd.cmd" },
--   capabilities = capabilities,
--   on_attach = on_attach,
--   -- Don't disable semantic tokens
--   -- on_init = on_init,
-- }

require("lspconfig.configs").bddlspserver = {
  default_config = require("custom.bdd").default_config,
}
lspconfig.bddlspserver.setup {
  filetypes = { "cucumber" },
  cmd = { "C:/Users/GZW/AppData/Local/nvim/lua/customlsp/bdd.cmd" },
  root_dir = function(_)
    return "C:/CMI-GitHub/cmi-metatool/"
  end,
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- setup lua ls
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

-- setup omnisharp
lspconfig.omnisharp.setup {
  cmd = { masonPath .. "/omnisharp.cmd" },

  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true,
      OrganizeImports = nil,
    },
    MsBuild = {
      -- If true, MSBuild project system will only load projects for files that
      -- were opened in the editor. This setting is useful for big C# codebases
      -- NOTE: Maybe enable for Metatool?
      LoadProjectsOnDemand = nil,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = true,
      EnableImportCompletion = true,
      -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
      -- true
      AnalyzeOpenDocumentsOnly = nil,
    },
    Sdk = {
      IncludePrereleases = true,
    },
  },
}
