-- ============================================================
-- 文件相关：备份/交换文件、持久化撤销、外部修改后自动重载、禁用内置 netrw
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ============================================================

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- 持久化撤销：关掉 Neovim 再打开同一个文件，仍能撤销（与「从外部改文件」的 AI
-- 协作时，除了 git 之外多一层「改回去」的网）。undodir 用默认的 stdpath("data")/undo
vim.opt.undofile = true

-- 当文件被外部程序修改时，自动加载
vim.opt.autoread = true
vim.bo.autoread = true
vim.o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
