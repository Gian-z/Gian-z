return {
  --require("plugins.oil"),
  require("plugins.lualine"),
  require("plugins.telescope"),
  require("plugins.typescript-tools"),
  require("plugins.catpuccin"),

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },
}
