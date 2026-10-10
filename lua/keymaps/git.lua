-- ============================================================
-- git / 审查相关键位：选择器（fzf-lua）与全局对比（diffview）
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载，文件名决定加载顺序）
-- ------------------------------------------------------------
-- 选择器名取自 fzf-lua 的注册表（init.lua 里的 git_files / git_status / git_diff /
-- git_commits / git_bcommits / git_branches）。
-- 分工：<leader>g* = 选择器，<leader>d* = diffview。
--
-- gitsigns **有意不在这里绑键位**，改用 :Gitsigns <子命令> 直接操作；命令清单与参数
-- 写在其插件文件 lua/plugins/gitsigns.lua 的头部注释里。
-- 这么定的原因：它的动作只在 git 仓库的 buffer 上有效（否则报 "Buffer is not
-- attached."），而 ]c/[c 又是 diff 模式的内置键，要绑就得监听它的 attach 事件做
-- buffer 局部绑定 —— 复杂度与收益不成比例。
-- ============================================================

-- ============================================================
-- fzf-lua：选择器
-- ============================================================

-- 工作区的改动文件列表（可预览后直接打开）
vim.keymap.set("n", "<leader>gs", "<Cmd>FzfLua git_status<CR>", { silent = true, desc = "Git status" })

-- 当前文件的历史提交：审 AI 改动时看「这块以前长什么样」
vim.keymap.set("n", "<leader>gb", "<Cmd>FzfLua git_bcommits<CR>", { silent = true, desc = "Git buffer commits" })

-- 整个仓库的提交历史
vim.keymap.set("n", "<leader>gc", "<Cmd>FzfLua git_commits<CR>", { silent = true, desc = "Git commits" })

-- 改动的 diff 视图
vim.keymap.set("n", "<leader>gd", "<Cmd>FzfLua git_diff<CR>", { silent = true, desc = "Git diff" })

-- 只列 git 跟踪的文件，避开 .venv/ 之类的噪音
vim.keymap.set("n", "<leader>gF", "<Cmd>FzfLua git_files<CR>", { silent = true, desc = "Git files" })

-- 分支列表 / 切换
vim.keymap.set("n", "<leader>gB", "<Cmd>FzfLua git_branches<CR>", { silent = true, desc = "Git branches" })

-- ============================================================
-- diffview：全局对比（一次看完本次改动涉及的所有文件）
-- ============================================================

vim.keymap.set("n", "<leader>dv", "<Cmd>DiffviewOpen<CR>", {
  silent = true,
  desc = "Diffview: 打开（工作区全部改动）",
})

-- 开 / 关切换（fork 的命令：已开则关、未开则开）
vim.keymap.set("n", "<leader>dt", "<Cmd>DiffviewToggle<CR>", { silent = true, desc = "Diffview: 打开 / 关闭" })

vim.keymap.set("n", "<leader>dc", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "Diffview: 关闭" })

vim.keymap.set("n", "<leader>dh", "<Cmd>DiffviewFileHistory %<CR>", {
  silent = true,
  desc = "Diffview: 当前文件的提交历史",
})
