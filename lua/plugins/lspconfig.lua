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
              "shfmt", -- formater
              "bash-language-server", -- lsp
              "stylua", -- formater
              "lua_ls", -- lsp
              "pyright", -- lsp
              "ruff", -- linter & formater
              "ruff_lsp", -- linter & formater
              "jq", -- json formater
            },
          })
        end,
      },
    },
    init = function()
      --init setting
    end,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp = require("lspconfig")
      lsp.bashls.setup({ capabilities = capabilities })
      lsp.pyright.setup({
        capabilities = capabilities,
        on_init = function(client)
          client.settings.python.pythonPath = require("whichpy.lsp").find_python_path(client.config.root_dir)
        end,
      })
      lsp.lua_ls.setup({
        capabilities = capabilities,
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
