-- 当进入插入模式或命令模式时，手动加载该插件
vim.api.nvim_create_autocmd(
  {"InsertEnter", "CmdlineEnter"}, 
  {
  once = true, -- 仅触发一次，防止重复加载
  callback = function()
    vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

    vim.pack.add(
      {
      "https://github.com/nanozuki/tabby.nvim",
      "https://github.com/nvim-tree/nvim-web-devicons",
      }
    )
    -- require("tabby").setup({preset = 'tab_only'})
    -- require("tabby").setup({preset = 'active_wins_at_tail'})
    require("tabby").setup({preset = 'tab_with_top_win'})
  end,
})  