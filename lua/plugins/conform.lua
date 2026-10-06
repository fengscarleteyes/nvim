vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "panache" },
    python = { "ruff_fix", "ruff_format" },
    -- json = { "prettier" },
    -- jsonc = { "prettier" },
    -- yaml = { "prettier" },
    -- toml = { "taplo" },
    -- html = { "prettier" },
    -- css = { "prettier" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    -- timeout_ms = 1000,
    lsp_format = "fallback",
  },
})
