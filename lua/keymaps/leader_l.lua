--stylua: ignore start
return {
  { "<leader>l", group = "Lsp" },
  { "<leader>lo", mode = { "n" }, "<Cmd>Outline<CR>",                     desc = "toggle outline",   noremap = true, silent = false },
  { "<leader>lr", mode = { "n" }, ":lua Snacks.rename.rename_file()<CR>", desc = "Rename File",      noremap = true, silent = false },
  -- TODO: add lsp formatting keymaps & conform.nvim keymaps
  }
-- stylua: ignore end
