-- ============================================================
-- 折叠：基于 treesitter 的表达式折叠
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ============================================================

-- 折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 999
vim.opt.foldenable = true
-- vim.opt.foldcolumn = '1'  -- 在侧边栏显示折叠指示器
vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
