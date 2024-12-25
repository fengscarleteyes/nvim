return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      formater = {
        "shfmt", -- bash formater
        "stylua", -- lua formater
        "prettier", -- formater
      },
      lsp = {
        "bashls", -- lsp
        "lua_ls", -- lsp
        "pyright", -- lsp
        "ruff", -- linter & formater
        "taplo", -- toml lsp formater
        "biome", -- js ts jsx json css GraphQL linter formater
      },
    },
    automatic_installation = true,
  },
  dependencies = { { "williamboman/mason.nvim", config = true } },
}
-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
-- TODO: use api rewrite to install formater and linters
