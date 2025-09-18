-- https://github.com/nanozuki/tabby.nvim

vim.o.showtabline = 2
vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

return {
  "nanozuki/tabby.nvim",
  event = "VimEnter",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("tabby").setup({ preset = "tab_only" })
  end,
}
