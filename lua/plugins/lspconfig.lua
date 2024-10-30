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
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
    end,
    keys = {
      { "<A-1>", vim.lsp.buf.hover, mode = "n", desc = "hover" },
      { "<A-2>", vim.lsp.buf.rename, mode = "n", desc = "rename" },
      { "<A-3>", vim.lsp.buf.definition, mode = "n", desc = "rename" },
      -- todo
      -- vim.lsp.buf.format()
      -- vim.lsp.buf.completion()
      -- vim.lsp.buf.formatting()
      -- vim.lsp.buf.references()
      -- vim.lsp.buf.code_action()
      -- vim.lsp.buf.declaration()
      -- vim.lsp.buf.server_ready()
      -- vim.lsp.buf.typehierarchy()
      -- vim.lsp.buf.implementation()
      -- vim.lsp.buf.incoming_calls()
      -- vim.lsp.buf.outgoing_calls()
      -- vim.lsp.buf.signature_help()
      -- vim.lsp.buf.document_symbol()
      -- vim.lsp.buf.execute_command()
      -- vim.lsp.buf.formatting_sync()
      -- vim.lsp.buf.type_definition()
      -- vim.lsp.buf.clear_references()
      -- vim.lsp.buf.range_formatting()
      -- vim.lsp.buf.workspace_symbol()
      -- vim.lsp.buf.range_code_action()
      -- vim.lsp.buf.document_highlight()
      -- vim.lsp.buf.add_workspace_folder()
      -- vim.lsp.buf.list_workspace_folders()
      -- vim.lsp.buf.remove_workspace_folder()
    },
  },
}
