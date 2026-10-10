-- ============================================================
-- git / 审查相关键位：选择器（fzf-lua）、逐块处置（gitsigns）、全局对比（diffview）
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载，文件名决定加载顺序）
-- ------------------------------------------------------------
-- 选择器名取自 fzf-lua 的注册表（init.lua 里的 git_files / git_status / git_diff /
-- git_commits / git_bcommits / git_branches）。
-- 分工：<leader>g* = 选择器，<leader>h* = gitsigns 逐块处置，<leader>d* = diffview。
--
-- gitsigns 的键位为什么靠事件绑、而不是直接全局绑：
--   1. 它的动作在未 attach 的 buffer 上会打印 "Buffer is not attached."，
--      全局绑会让非 git 文件里按 <leader>hs 变成报错；
--   2. ]c / [c 是 diff 模式的内置键（跳到下一处差异），全局覆盖会把它吃掉。
-- 所以监听 gitsigns 的 `User GitSignsUpdate`（源码 status.lua:15 用 data.buffer 传出
-- buffer 号），只对 attach 到的那个 buffer 做局部绑定 —— 效果与写在插件 on_attach 里
-- 一致，但键位定义集中在 keymaps/。
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
-- gitsigns：逐块处置（buffer 局部，attach 之后才绑）
-- ============================================================

local bound = {} -- 已绑过键位的 buffer：GitSignsUpdate 会随每次状态更新重复触发

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    bound[args.buf] = nil
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function(args)
    local bufnr = args.data and args.data.buffer
    if not bufnr or bound[bufnr] then
      return
    end
    bound[bufnr] = true

    local gs = require("gitsigns")

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    -- 在改动块之间跳
    map("]c", function()
      gs.nav_hunk("next")
    end, "Gitsigns: 下一个改动")
    map("[c", function()
      gs.nav_hunk("prev")
    end, "Gitsigns: 上一个改动")

    -- 逐块处置：暂存 / 退回 / 撤销暂存
    map("<leader>hs", gs.stage_hunk, "Gitsigns: 暂存本块改动")
    map("<leader>hr", gs.reset_hunk, "Gitsigns: 退回本块改动")
    map("<leader>hS", gs.stage_buffer, "Gitsigns: 暂存整个文件")
    map("<leader>hR", gs.reset_buffer, "Gitsigns: 退回整个文件")
    map("<leader>hu", gs.undo_stage_hunk, "Gitsigns: 撤销上次暂存")

    -- 看：浮窗预览 / 整屏对比 / 本行来历
    map("<leader>hp", gs.preview_hunk, "Gitsigns: 预览本块改动")
    map("<leader>hd", gs.diffthis, "Gitsigns: 本块与本块基线对比")
    map("<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Gitsigns: 本行 blame")

    -- 把本文件所有改动灌进 quickfix，用 :cnext / :copen 逐条过
    map("<leader>hq", gs.setqflist, "Gitsigns: 改动列表 → quickfix")

    -- 显示开关
    map("<leader>hw", gs.toggle_word_diff, "Gitsigns: 词级差异开关")
    map("<leader>hB", gs.toggle_current_line_blame, "Gitsigns: 本行 blame 开关")
  end,
})

-- ============================================================
-- diffview：全局对比（一次看完本次改动涉及的所有文件）
-- ============================================================

vim.keymap.set(
  "n",
  "<leader>dv",
  "<Cmd>DiffviewOpen<CR>",
  { silent = true, desc = "Diffview: 打开（工作区全部改动）" }
)
vim.keymap.set("n", "<leader>dc", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "Diffview: 关闭" })
vim.keymap.set("n", "<leader>dh", "<Cmd>DiffviewFileHistory %<CR>", {
  silent = true,
  desc = "Diffview: 当前文件的提交历史",
})
