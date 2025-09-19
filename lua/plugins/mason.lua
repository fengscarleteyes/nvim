-- https://github.com/williamboman/mason.nvim

return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "stylua", -- lua formater
      "lua-language-server", -- lsp
      -- "prettier", -- Angular, CSS, Flow, GraphQL, HTML, JSON, JSX, JavaScript, LESS, Markdown, SCSS, TypeScript, Vue, YAML formater
      -- "pyright", -- python lsp
      "ty", -- python type checker lsp
      "ruff", -- python linter & formater
      -- "taplo", -- toml lsp & formater
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)
    local ms = require("mason-registry")
    local function auto_install_tools(tool)
      if not ms.is_installed(tool) then
        if ms.has_package(tool) then
          vim.cmd([[MasonInstall ]] .. tool)
        else
          vim.notify("mason no search tool: " .. tool)
        end
      end
    end
    for _, tool in ipairs(opts.ensure_installed) do
      auto_install_tools(tool)
    end
  end,
}
