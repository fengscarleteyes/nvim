return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "bashls", -- bash lsp
      "shellcheck", -- bash linter
      "shfmt", -- bash formater
      "stylua", -- lua formater
      "lua_ls", -- lsp
      "prettier", -- Angular, CSS, Flow, GraphQL, HTML, JSON, JSX, JavaScript, LESS, Markdown, SCSS, TypeScript, Vue, YAML formater
      "pyright", -- python lsp
      "ruff", -- python linter & formater
      "taplo", -- toml lsp & formater
    },
  },
  config = function(_, opts)
    local ms = require("mason-registry")
    local function auto_install_tools(tool)
      if not ms.is_installed(tool) and ms.has_package(tool) then
        vim.cmd([[MasonInstall ]] .. tool)
      end
    end
    for _, tool in ipairs(opts.ensure_installed) do
      auto_install_tools(tool)
    end
  end,
  dependencies = { { "williamboman/mason.nvim", config = true } },
}

-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
