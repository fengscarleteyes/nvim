-- https://github.com/nvimdev/indentmini.nvim

-- vim.cmd.highlight('IndentLine guifg=#123456')
-- vim.cmd.highlight('IndentLineCurrent guifg=#123456')

return {
  "nvimdev/indentmini.nvim",
  -- enabled = false,
  config = function()
    require("indentmini").setup() -- use default config
  end,
}
