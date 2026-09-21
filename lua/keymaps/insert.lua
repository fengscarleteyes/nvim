-- ============================================================
-- 插入模式：用 <C-h>/<C-j>/<C-k>/<C-l> 移动光标
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载）
-- 注：原 keymaps/init.lua 里 <C-l> 定义了两遍（内容完全相同），此处去重。
-- ============================================================

vim.keymap.set("i", "<C-h>", "<Left>", { silent = true, desc = "Move left" })
vim.keymap.set("i", "<C-j>", "<Down>", { silent = true, desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { silent = true, desc = "Move up" })
vim.keymap.set("i", "<C-l>", "<Right>", { silent = true, desc = "Move right" })
