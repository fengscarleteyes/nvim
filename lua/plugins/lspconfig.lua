-- https://github.com/neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "folke/lazydev.nvim",
    "saghen/blink.cmp",
    "williamboman/mason.nvim",
    -- "williamboman/mason-lspconfig.nvim",
  },
  init = function()
    --init setting
  end,
  opts = {
    servers = {
      taplo = {},
      -- bashls = {},
      pyright = {},
      ruff = {},
      -- nushell = {
      --   cmd = { "nu", "--lsp" },
      --   filetypes = { "nu" },
      --   single_file_support = true,
      -- },
      lua_ls = {
        on_init = function(client)
          client.server_capabilities.semanticTokensProvider = nil
        end,
        settings = {
          Lua = {
            lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                  "${3rd}/luv/library",
                },
              },
            },
          },
        },
      },
    },
  },
  config = function(_, opts)
    local lsp = require("lspconfig")
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      -- vim.lsp.enable(server)
      lsp[server].setup(config)
    end
  end,
}
