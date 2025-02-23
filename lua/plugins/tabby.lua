-- https://github.com/nanozuki/tabby.nvim
vim.o.showtabline = 2
vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

return {
  "nanozuki/tabby.nvim",
  -- enabled = false,
  event = "VimEnter", -- if you want lazy load, see below
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("tabby").setup({
      preset = "active_wins_at_tail",
    })
  end,
}
