-- ============================================================
-- git 相关选择器：全部走 fzf-lua 内置 provider，不需要额外插件
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载，文件名决定加载顺序）
-- ------------------------------------------------------------
-- 选择器名取自 fzf-lua 的注册表（init.lua 里 git_files / git_status /
-- git_diff / git_commits / git_bcommits / git_branches）。
-- 键位分工：<leader>g* = 选择器，<leader>h* = gitsigns 逐块处置，
-- <leader>d* = diffview 全局对比（见 lua/plugins/diffview.lua）。
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
