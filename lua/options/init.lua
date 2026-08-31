-- local check_nushell = io.popen("nu --help")
--
-- if check_nushell and check_nushell:read() == "The nushell language and shell." then
--   vim.opt.shell = "nu"
--   -- vim.opt.sh = "nu"
--   vim.opt.shelltemp = false
--   vim.opt.shellredir = "out+err> %s"
--   -- flags for nu:
--   -- * `--stdin`       redirect all input to -c
--   -- * `--no-newline`  do not append `\n` to stdout
--   -- * `--commands -c` execute a command
--   vim.opt.shellcmdflag = "--stdin --no-newline -c"
--
--   -- disable all escaping and quoting
--   vim.opt.shellxescape = ""
--   vim.opt.shellxquote = ""
--   vim.opt.shellquote = ""
--   -- vim.fn.stdpath("data")
-- else
--   if vim.fn.has("win32") == 1 then
--     vim.opt.shell = "powershell.exe"
--   else
--     vim.opt.shell = "bash"
--   end
-- end

-- if vim.fn.has("win32") == 1 then
--   vim.opt.shell = "cmd.exe"
-- else
--   vim.opt.shell = "bash"
-- end

-- vim.opt.shadafile = "NONE"

-- 禁用启动时的版本提示
vim.opt.shortmess:append("I")

-- Neovim default updatetime is 4000
vim.opt.updatetime = 200

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "ucs-bom,utf-8,default,latin1"

vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 禁止折行
vim.opt.wrap = false
vim.opt.scroll = 0 -- 1

-- jk移动时光标下上方保留N行
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- 行结尾可以跳到下一行
vim.opt.whichwrap = "b,s,<,>,[,],h,l"

-- 不可见字符的显示
-- vim.opt.list = false
vim.opt.list = true

vim.opt.listchars = "space:·,trail:,tab:,eol:"
-- vim.opt.listchars = "space:·,trail:,tab:,eol:"
-- vim.opt.listchars = "space:󰧟,trail:󰃉,tab:,eol:󱨉"
-- vim.opt.listchars = 'space:󰧟,trail:󱁐,tab:,eol:󰬧'
-- vim.opt.listchars = 'space:󰧟,trail:󱁐,tab:󰧙󰢤󰧛,eol:󰬧'
-- vim.opt.listchars = "space:󰧟,tab:,eol:"

-- 使用相对行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 3

-- 高亮所在行列
vim.api.nvim_set_hl(0, "CursorLine", { reverse = true })
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.splitkeep = "screen"

-- 长度参考线
vim.opt.colorcolumn = "100"

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- 补全增强
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum,tagfile"

-- 总是显示标签栏 0 1 2
vim.opt.showtabline = 2

-- 新行对齐当前行
vim.opt.breakindent = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- 折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 999
vim.opt.foldenable = true
-- vim.opt.foldcolumn = '1'  -- 在侧边栏显示折叠指示器
vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

-- 当文件被外部程序修改时，自动加载
vim.opt.autoread = true
vim.bo.autoread = true

-- 搜索
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.opt.mouse = "nv"
-- vim.opt.mouse = "" -- disable mouse
vim.opt.mouse = "a"
vim.opt.mousemoveevent = true
vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
-- vim.cmd("aunmenu PopUp.-2-")

-- vim.opt.autowrite = true -- Enable auto write
-- vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
vim.opt.completeopt = "menu,menuone,noselect,popup"

-- vim.opt.signcolumn = "number"
vim.opt.signcolumn = "yes"

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- 状态栏
vim.opt.laststatus = 3
vim.g.showmode = true

-- 补全菜单背景透明
vim.opt.pumblend = 10
-- vim.opt.pumheight = 5

-- disable check warn
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
