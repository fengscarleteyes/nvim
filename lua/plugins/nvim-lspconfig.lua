-- https://github.com/neovim/nvim-lspconfig
local servers = {
  taplo = {},
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

return {
  "neovim/nvim-lspconfig",
  dependencies = "folke/lazydev.nvim",
  event = "BufEnter",
  config = function()
    for server, config in pairs(servers) do
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
