-- ============================================================
-- 界面显示：折行/滚动、不可见字符、行号、光标行列、标签栏、鼠标、颜色
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ============================================================

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

-- 总是显示标签栏 0 1 2
vim.opt.showtabline = 2

-- vim.opt.mouse = "nv"
-- vim.opt.mouse = "" -- disable mouse
vim.opt.mouse = "a"
vim.opt.mousemoveevent = true
vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
-- vim.cmd("aunmenu PopUp.-2-")

-- vim.opt.signcolumn = "number"
vim.opt.signcolumn = "yes"

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- 状态栏
vim.opt.laststatus = 3
vim.g.showmode = true
