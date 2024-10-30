-- NOTE: UTF-8
vim.g.encoding = "UTF-8"
vim.o.fileencoding = "utf-8"

-- 禁止折行
vim.o.wrap = false
vim.o.scroll = 0 -- 1

-- jk移动时光标下上方保留N行
vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

-- 行结尾可以跳到下一行
vim.o.whichwrap = "b,s,<,>,[,],h,l"

-- 使用相对行号
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 2

-- 高亮所在行列
vim.o.cursorline = true
-- vim.o.cursorcolumn = true
vim.o.splitkeep = "screen"

-- 长度参考线
vim.o.colorcolumn = "100"

-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- 补全增强
vim.o.wildmenu = true

-- 总是显示标签栏 0 1 2
vim.o.showtabline = 2

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

vim.o.signcolumn = "yes"

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.o.termguicolors = true

-- 状态栏
vim.o.laststatus = 3
vim.g.showmode = true

-- 补全菜单背景透明
vim.o.pumblend = 50
vim.o.pumheight = 5

-- vim inlay hint
-- vim.lsp.inlay_hint.enable()
