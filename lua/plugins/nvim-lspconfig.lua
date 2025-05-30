-- https://github.com/neovim/nvim-lspconfig
local servers = {
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
    }


local use = require('strive').use

use("neovim/nvim-lspconfig")
  :depends("folke/lazydev.nvim")
  :config(
    function()
      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end
  )

