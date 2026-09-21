-- ============================================================
-- FzfLua：<leader>f* 系列
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载）
-- ============================================================

vim.keymap.set("n", "<leader>ff", "<Cmd>FzfLua files<CR>", { silent = true, desc = "FzfLua files" })
vim.keymap.set("n", "<leader>fc", "<Cmd>FzfLua colorschemes<CR>", { silent = true, desc = "FzfLua colorschemes" })
vim.keymap.set("n", "<leader>fg", "<Cmd>FzfLua live_grep<CR>", { silent = true, desc = "FzfLua live_grep" })
vim.keymap.set("n", "<leader>fh", "<Cmd>FzfLua helptags<CR>", { silent = true, desc = "FzfLua helptags" })
vim.keymap.set("n", "<leader>fb", "<Cmd>FzfLua buffers<CR>", { silent = true, desc = "FzfLua buffers" })
vim.keymap.set("n", "<leader>fl", "<Cmd>FzfLua lines<CR>", { silent = true, desc = "FzfLua lines" })
vim.keymap.set("n", "<leader>ft", "<Cmd>FzfLua tabs<CR>", { silent = true, desc = "FzfLua tabs" })
vim.keymap.set("n", "<leader>fj", "<Cmd>FzfLua lgrep_curbuf<CR>", { silent = true, desc = "FzfLua lgrep_curbuf" })
vim.keymap.set("n", "<leader>fd", "<Cmd>FzfLua diagnostics_document<CR>", {
  silent = true,
  desc = "FzfLua diagnostics_document",
})
vim.keymap.set("n", "<leader>fD", "<Cmd>FzfLua diagnostics_workspace<CR>", {
  silent = true,
  desc = "FzfLua diagnostics_workspace",
})
vim.keymap.set("n", "<leader>fk", "<Cmd>FzfLua keymaps<CR>", { silent = true, desc = "FzfLua keymaps" })
