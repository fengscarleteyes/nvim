-- ============================================================
-- diff 模式显示：审查代码改动（:DiffviewOpen、:diffsplit、git diff）时的对比外观
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ------------------------------------------------------------
-- 用 :append 追加而不是覆盖：Neovim 0.12 的默认值已经很好，实测为
--   internal,filler,closeoff,indent-heuristic,inline:char,linematch:40
-- 其中 linematch 已默认开启（把改动行左右对齐），不需要再补。
-- ============================================================

-- algorithm:histogram：比默认的 myers 更会把「移动过的代码块」认成同一块，
--   审 AI 大段重排（函数换位置、语句顺序调整）时误报明显更少
-- vertical：:diffsplit / :vimdiff 默认左右分屏，逐 hunk 对照比上下分屏好读
vim.opt.diffopt:append({ "algorithm:histogram", "vertical" })
