-- https://github.com/neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
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
      bashls = {},
      ty = {},
      pyright = {},
      ruff = {},
      nushell = {
        cmd = { "nu", "--lsp" },
        filetypes = { "nu" },
        single_file_support = true,
      },
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) ---@diagnostic disable-line
              -- and (vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc"))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                vim.api.nvim_get_runtime_file("", true),
                vim.fn.expand("$VIMRUNTIME/lua"),
                -- Depending on the usage, you might want to add additional paths here.
                "${3rd}/luv/library",
                -- "${3rd}/busted/library",
              },
              -- library = vim.api.nvim_get_runtime_file("", true),
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
