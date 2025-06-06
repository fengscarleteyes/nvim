-- local check_nushell = io.popen("nu --help")
--
-- if check_nushell and check_nushell:read() == "The nushell language and shell." then
--   vim.o.shell = "nu"
--   -- vim.opt.sh = "nu"
--   vim.o.shelltemp = false
--   vim.o.shellredir = "out+err> %s"
--   -- flags for nu:
--   -- * `--stdin`       redirect all input to -c
--   -- * `--no-newline`  do not append `\n` to stdout
--   -- * `--commands -c` execute a command
--   vim.o.shellcmdflag = "--stdin --no-newline -c"
--
--   -- disable all escaping and quoting
--   vim.o.shellxescape = ""
--   vim.o.shellxquote = ""
--   vim.o.shellquote = ""
--   -- vim.fn.stdpath("data")
-- else
--   if vim.fn.has("win32") == 1 then
--     vim.o.shell = "powershell.exe"
--   else
--     vim.o.shell = "bash"
--   end
-- end

-- if vim.fn.has("win32") == 1 then
--   vim.o.shell = "cmd.exe"
-- else
--   vim.o.shell = "bash"
-- end

-- vim.o.shadafile = "NONE"

-- 禁用启动时的版本提示
vim.opt.shortmess:append("I")

-- Neovim default updatetime is 4000
vim.o.updatetime = 200

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.g.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 禁止折行
vim.o.wrap = false
vim.o.scroll = 0 -- 1

-- jk移动时光标下上方保留N行
vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

-- 行结尾可以跳到下一行
vim.o.whichwrap = "b,s,<,>,[,],h,l"

-- 不可见字符的显示
vim.o.list = false
-- vim.o.list = true

vim.o.listchars = "space:·,trail:,tab:,eol:"
-- vim.o.listchars = "space:·,trail:,tab:,eol:"
-- vim.o.listchars = "space:󰧟,trail:󰃉,tab:,eol:󱨉"
-- vim.o.listchars = 'space:󰧟,trail:󱁐,tab:,eol:󰬧'
-- vim.o.listchars = 'space:󰧟,trail:󱁐,tab:󰧙󰢤󰧛,eol:󰬧'
-- vim.o.listchars = "space:󰧟,tab:,eol:"

-- 使用相对行号
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3

-- 高亮所在行列
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.splitkeep = "screen"

-- 长度参考线
vim.o.colorcolumn = "100"

-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- 补全增强
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "pum,tagfile"

-- 总是显示标签栏 0 1 2
vim.o.showtabline = 2

-- 新行对齐当前行
vim.o.breakindent = true
vim.o.autoindent = true
vim.o.smartindent = true

-- 折叠
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 999
vim.opt.foldenable = false

-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true

-- 搜索
vim.o.ignorecase = true
vim.o.smartcase = true

-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.o.mouse = "nv"
-- vim.o.mouse = "" -- disable mouse
vim.o.mouse = "a"
vim.o.mousemoveevent = true
vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
-- vim.cmd("aunmenu PopUp.-2-")

-- vim.opt.autowrite = true -- Enable auto write
-- vim.o.clipboard = "unnamedplus" -- Sync with system clipboard
vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
vim.o.completeopt = "menu,menuone,noselect"

-- vim.o.signcolumn = "number"
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
vim.o.pumblend = 10
-- vim.o.pumheight = 5
