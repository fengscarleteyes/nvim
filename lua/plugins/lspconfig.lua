-- https://github.com/neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "folke/lazydev.nvim",
    "saghen/blink.cmp",
    "williamboman/mason.nvim",
  },
  init = function()
    --init setting
  end,
  opts = {
    servers = {
      taplo = {},
      -- bashls = {},
      pyright = {},
      ty = {},
      ruff = {},
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
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
