vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup({
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = true, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})
