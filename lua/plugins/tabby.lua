vim.pack.add({
  "https://github.com/nanozuki/tabby.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

-- require("tabby").setup({preset = 'tab_only'})
-- require("tabby").setup({preset = 'active_wins_at_tail'})
require("tabby").setup({preset = 'tab_with_top_win'})
