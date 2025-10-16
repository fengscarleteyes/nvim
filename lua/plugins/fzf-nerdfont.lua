-- https://github.com/stephansama/fzf-nerdfont.nvim

return {
  "stephansama/fzf-nerdfont.nvim",
  lazy = true,
  build = ":FzfNerdfont generate",
  dependencies = { "ibhagwan/fzf-lua" },
  cmd = "FzfNerdfont",
  -- keys = {
  --     { "<leader>fi", "<CMD>FzfNerdfont<CR>", desc= "Open fzf nerd font picker" }
  -- },
  ---@module 'fzf-nerdfont'
  ---@type FzfNerdFontOpts
  opts = {},
}
