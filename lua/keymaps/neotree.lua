-- ============================================================
-- 文件树：<leader>fe（Neotree 开关）
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载）
-- ============================================================

vim.keymap.set("n", "<leader>fe", "<cmd>Neotree filesystem toggle<CR>", { silent = true, desc = "Neotree" })
