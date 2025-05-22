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
      biome = {},
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
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) ---@diagnostic disable-line
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using (most
              -- likely LuaJIT in the case of Neovim)
              version = "LuaJIT",
              -- Tell the language server how to find Lua modules same way as Neovim
              -- (see `:h lua-module-load`)
              path = {
                "lua/?.lua",
                "lua/?/init.lua",
              },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                -- Depending on the usage, you might want to add additional paths
                -- here.
                -- '${3rd}/luv/library'
                -- '${3rd}/busted/library'
              },
              -- Or pull in all of 'runtimepath'.
              -- NOTE: this is a lot slower and will cause issues when working on
              -- your own configuration.
              -- See https://github.com/neovim/nvim-lspconfig/issues/3189
              -- library = {
              --   vim.api.nvim_get_runtime_file('', true),
              -- }
            },
          })
        end,
        settings = {
          Lua = {},
        },
      },
    },
  },
  config = function(_, opts)
    local lsp = require("lspconfig")
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      vim.lsp.enable(server)
      lsp[server].setup(config)
    end
  end,
}
