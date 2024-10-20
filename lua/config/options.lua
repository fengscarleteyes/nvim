-- NOTE: UTF-8
vim.g.encoding = "UTF-8"
vim.o.fileencoding = "utf-8"

-- 禁止折行
vim.opt.wrap = false
vim.opt.scroll = 0 -- 1

-- jk移动时光标下上方保留N行
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- 使用相对行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2

-- 高亮所在行列
vim.opt.cursorline = true
-- vim.o.cursorcolumn = true
vim.opt.splitkeep = "screen"

-- 长度参考线
vim.opt.colorcolumn = "100"

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- 补全增强
vim.opt.wildmenu = true

-- 总是显示标签栏 0 1 2
vim.o.showtabline = 2
-- vim.o.showtabline = 0

-- 新行对齐当前行
vim.o.autoindent = true
vim.o.smartindent = true

-- 折叠
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 999

-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true

-- 搜索
vim.o.ignorecase = true
vim.o.smartcase = true

-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.mouse = "nv"

-- vim.opt.autowrite = true -- Enable auto write
vim.o.clipboard = "unnamedplus" -- Sync with system clipboard
vim.o.completeopt = "menu,menuone,noselect"

vim.o.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.o.termguicolors = true

-- 状态栏
vim.o.laststatus = 3 -- global statusline
vim.o.showmode = true -- Dont show mode since we have a statusline

-- 补全菜单背景透明
vim.o.pumblend = 50
vim.o.pumheight = 5