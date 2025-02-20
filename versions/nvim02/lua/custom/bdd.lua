local default_root = "C:/CMI-GitHub/cmi-metatool"
local tool_key = "bddlspserver"

local M = {}

M.default_config = {
  name = tool_key,
  cmd = { tool_key },
  root_dir = default_root,
}

M.setup = function(user_config)
  -- Merge incoming arguments to default config
  for k, v in pairs(user_config) do
    M.default_config[k] = v
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cucumber",
    callback = function()
      local client = vim.lsp.start_client(M.default_config)
      if not client then
        vim.notify "BDD-Lsp: Client not configured correctly"
        return
      end

      vim.lsp.buf_attach_client(0, client)
    end,
  })
end

return M
