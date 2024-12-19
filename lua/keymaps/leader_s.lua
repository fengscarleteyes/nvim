--stylua: ignore start
return {
  { "<leader>s", group = "Surround" },
  { "<leader>ss", mode = { "n" }, "<Plug>(nvim-surround-normal-cur)",      desc = "surround normal cur",      noremap = true, silent = false },
  { "<leader>sS", mode = { "n" }, "<Plug>(nvim-surround-normal)",          desc = "surround normal",          noremap = true, silent = false },
  { "<leader>sd", mode = { "n" }, "<Plug>(nvim-surround-delete)",          desc = "surround delete",          noremap = true, silent = false },
  { "<leader>sl", mode = { "n" }, "<Plug>(nvim-surround-normal-cur-line)", desc = "surround normal cur line", noremap = true, silent = false },
  { "<leader>sL", mode = { "n" }, "<Plug>(nvim-surround-normal-line)",     desc = "surround normal line",     noremap = true, silent = false },
  { "<leader>sr", mode = { "n" }, "<Plug>(nvim-surround-change)",          desc = "surround change",          noremap = true, silent = false },
  { "<leader>sR", mode = { "n" }, "<Plug>(nvim-surround-change-line)",     desc = "surround change line",     noremap = true, silent = false },
  { "<leader>sv", mode = { "x" }, "<Plug>(nvim-surround-visual-line)",     desc = "surround visual line",     noremap = true, silent = false },
  { "<leader>sV", mode = { "x" }, "<Plug>(nvim-surround-visual)",          desc = "surround visual",          noremap = true, silent = false },
  -- { "setket",     mode = { "i" }, "<Plug>(nvim-surround-insert)",          desc = "surround insert",          noremap = true, silent = false },
  -- { "setket",     mode = { "i" }, "<Plug>(nvim-surround-insert-line)",     desc = "surround insert line",     noremap = true, silent = false },
}
-- stylua: ignore end
