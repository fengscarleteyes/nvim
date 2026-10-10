vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

-- 本插件**有意不绑键位**（曾绑过一套 <leader>h*，已按用户要求移除），
-- 改用 `:Gitsigns <子命令>` 直接操作。常用命令：
--
--   :Gitsigns nav_hunk next --target=all      下一个改动；--target=all 才会扫到已暂存的
--   :Gitsigns nav_hunk prev --target=all        改动（默认只扫未暂存的，见 doc/gitsigns.txt:585）
--   :Gitsigns stage_hunk                      暂存光标所在 hunk（在已暂存的记号上执行 = 取消暂存）
--   :Gitsigns reset_hunk                      退回（丢弃）光标所在 hunk
--   :Gitsigns stage_buffer / reset_buffer     整个文件的暂存 / 退回
--   :Gitsigns reset_buffer_index              整个文件取消暂存（真的对文件跑 git reset）
--   :Gitsigns preview_hunk                    浮窗预览本块改动
--   :Gitsigns diffthis                        本块与本块基线对比
--   :Gitsigns blame_line --full               本行 blame
--   :Gitsigns setqflist attached --open       本文件改动 → quickfix（target: 0|attached|all）
--   :Gitsigns toggle_word_diff                词级差异开关
--   :Gitsigns toggle_current_line_blame       本行 blame 开关
--
-- 共 40 个子命令，`:Gitsigns <Tab>` 可补全；标志用双横线（--full / --target=all），
-- 参数表由插件自动生成于 gitsigns/cli/completion/generated.lua。
--
-- 配置只留显示相关。word_diff：审查改动用 —— 一行里只换了个 token 时才看得出改在哪个词。
require("gitsigns").setup({
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})
