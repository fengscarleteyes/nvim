return {
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
            "jq", -- json formater
            "taplo", -- toml lsp formater
            -- TODO: add https://biomejs.dev/zh-cn/
          },
        })
      end,
    },
  },
  init = function()
    --init setting
  end,
  config = function()
    local lsp = require("lspconfig")
    lsp.taplo.setup({})
    lsp.bashls.setup({})
    lsp.pyright.setup({})
    lsp.ruff.setup({})
    lsp.lua_ls.setup({
      settings = {
        Lua = {
          hint = {
            enable = true,
            setType = false,
            paramType = true,
            paramName = "Disable",
            semicolon = "Disable",
            arrayIndex = "Disable",
          },
          codeLens = {
            enable = true,
          },
          -- completion = {
          --   callSnippet = "Replace",
          -- },
          doc = {
            privateName = { "^_" },
          },
          runtime = {
            version = "LuaJIT",
            path = {
              -- "?.lua",
              -- "?/init.lua",
              -- vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
              -- vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
              -- "/usr/share/5.3/?.lua",
              -- "/usr/share/lua/5.3/?/init.lua",
            },
          },
          diagnostics = {
            globals = {
              "vim",
              "require",
            },
          },
          workspace = {
            library = {
              -- "${3rd}/luv/library",
              -- "${3rd}/busted/library",
              -- vim.env.VIMRUNTIME,
              vim.api.nvim_get_runtime_file("", true),
              -- "/usr/share/lua/5.3",
              -- vim.fn.expand("~/.luarocks/share/lua/5.3"),
            },
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
  end,
}
