return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "saghen/blink.cmp",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  init = function()
    --init setting
  end,
  opts = {
    servers = {
      taplo = {},
      biome = {},
      bashls = {},
      -- pyright = {},
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "openFilesOnly",
              inlayHints = {
                callArgumentNames = true,
              },
            },
          },
        },
      },
      ruff = {},
      nushell = {
        cmd = { "nu", "--lsp" },
        filetypes = { "nu" },
        single_file_support = true,
      },
      lua_ls = {
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
          doc = {
            privateName = { "^_" },
          },
          runtime = {
            version = "LuaJIT",
            path = {
              "?.lua",
              "?/init.lua",
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
              vim.env.VIMRUNTIME,
              vim.api.nvim_get_runtime_file("", true),
            },
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    },
  },
  config = function(_, opts)
    local lsp = require("lspconfig")
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      lsp[server].setup(config)
    end
  end,
}
