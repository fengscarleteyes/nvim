--stylua: ignore start
return {
  { "<leader>l", group = "Lsp" },
  { "<leader>lo", mode = { "n" }, "<Cmd>Outline<CR>",                     desc = "toggle outline",   noremap = true, silent = false },
  { "<leader>lr", mode = { "n" }, ":lua Snacks.rename.rename_file()<CR>", desc = "Rename File",      noremap = true, silent = false },
  { "<leader>lj", mode = { "n" }, ":lua Snacks.scope.jump()<CR>",         desc = "Scope Jump",       noremap = true, silent = false },
  { "<leader>lt", mode = { "n" }, ":lua Snacks.scope.textobject()<CR>",   desc = "Scope Textobject", noremap = true, silent = false },
  -- TODO: add lsp formatting keymaps & conform.nvim keymaps
  }
-- stylua: ignore end
