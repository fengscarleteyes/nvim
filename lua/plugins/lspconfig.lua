return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      {
        "williamboman/mason-lspconfig.nvim",
        config = true,
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
          require("mason-tool-installer").setup({
            ensure_installed = {
              "lua_ls",
              "stylua",
              "ruff",
              "ruff_lsp",
              "pyright",
            },
          })
        end,
      },
    },
    init = function()
      --init setting
    end,
    config = function()
      -- here
      local lsp = require("lspconfig")
      lsp.pyright.setup({})
      lsp.lua_ls.setup({
        settings = {
          Lua = {
            hint = { enable = true },
            runtime = {
              version = "LuaJIT",
              path = {
                "?.lua",
                "?/init.lua",
                vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
                vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
                "/usr/share/5.3/?.lua",
                "/usr/share/lua/5.3/?/init.lua",
              },
            },
            diagnostics = {
              globals = { "vim", "require" },
            },
            workspace = {
              library = {
                vim.api.nvim_get_runtime_file("", true),
                "/usr/share/lua/5.3",
                vim.fn.expand("~/.luarocks/share/lua/5.3"),
              },
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
    end,
  },
}
