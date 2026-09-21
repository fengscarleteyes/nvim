-- ============================================================
-- 补全：命令行补全（wildmenu）与插入模式补全菜单（completeopt）
-- 注意：本文件里 vim.o.completeopt 会覆盖上面的 vim.opt.completeopt，
--       最终生效的是末尾的 "menuone,noinsert,noselect"（与原 options/init.lua 一致）。
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ============================================================

-- 补全增强
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum,tagfile"

vim.opt.completeopt = "menu,menuone,noselect,popup"

-- 补全菜单背景透明
vim.opt.pumblend = 10
-- vim.opt.pumheight = 5

-- 开启原生自动补全
vim.o.autocomplete = true

-- 设置补全菜单行为
vim.o.completeopt = "menuone,noinsert,noselect"
