-- https://github.com/nanozuki/tabby.nvim

vim.o.showtabline = 2
vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

return {
  "nanozuki/tabby.nvim",
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  ---@type TabbyConfig
  opte = {
    preset = "tab_only",
  },
  config = function(_, opts)
    require("tabby").setup(opts)
  end,
}
