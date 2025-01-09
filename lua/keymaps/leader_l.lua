local function lsp_readme()
  vim.lsp.buf.rename()
end
--stylua: ignore start
return {
  { "<leader>l", group = "Lsp" },
  { "<leader>lo", mode = { "n" }, "<Cmd>Outline<CR>",      desc = "toggle outline", noremap = true, silent = false },
  { "<leader>lr", mode = { "n" }, lsp_readme, desc = "Rename",         noremap = true, silent = false },
  -- TODO: add lsp formatting keymaps & conform.nvim keymaps : LspUI
-- vim.keymap.set('n', 'gD', '<CMD>Glance definitions<CR>')
-- vim.keymap.set('n', 'gR', '<CMD>Glance references<CR>')
-- vim.keymap.set('n', 'gY', '<CMD>Glance type_definitions<CR>')
-- vim.keymap.set('n', 'gM', '<CMD>Glance implementations<CR>')
  }
-- stylua: ignore end
