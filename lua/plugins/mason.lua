return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "shfmt", -- bash formater
      "stylua", -- lua formater
      "prettier", -- formater
      "bashls", -- lsp
      "lua_ls", -- lsp
      "pyright", -- lsp
      "ruff", -- linter & formater
      "taplo", -- toml lsp formater
      "biome", -- js ts jsx json css GraphQL linter formater
    },
  },
  -- automatic_installation = true,
  config = function(_, opts)
    local ms = require("mason-registry")
    local function auto_install_tools(tool)
      if not ms.is_installed(tool) and ms.has_package(tool) then
        vim.cmd([[MasonInstall ]] .. tool)
      end
    end
    for tool in ipairs(opts.ensure_installed) do
      auto_install_tools(tool)
    end
  end,
  dependencies = { { "williamboman/mason.nvim", config = true } },
}

-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
