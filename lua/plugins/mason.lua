return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "lua_ls", -- lsp
      "pyright", -- lsp
      "ruff", -- linter & formater & lsp
      "taplo", -- toml lsp & formater
      "biome", -- js ts jsx json css GraphQL linter & formater & lsp
    },
    automatic_installation = true,
  },
  dependencies = { { "williamboman/mason.nvim", config = true } },
}

-- [[
TODO:
local m = require("mason-registry")
if not m.is_installed("stylua") and m.has_package("stylua") then
	print(m.get_installed_package_names())
	vim.cmd([[<CMD>MasonInstall stylua<CR>]])
else
	print(1)
end
]]

