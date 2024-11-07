return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
      },
      format_on_save = {
        -- These options will be passed to conform.format()
        -- timeout_ms = 500,
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
      formatters = {
        ruff_format = {
          command = "ruff",
          prepend_args = { "format" },
        },
      },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        require("conform").format({ bufnr = args.buf })
      end,
    })
  end,
}
