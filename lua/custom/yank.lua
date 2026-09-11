-- ============================================================
-- 复制（yank）后短暂高亮被复制的内容
-- ------------------------------------------------------------
-- 高亮组用 IncSearch（跟随配色方案），时长 2000ms。
-- ============================================================

local HIGHLIGHT_TIMEOUT = 2000 -- 高亮时长（毫秒）
local HIGHLIGHT_GROUP = "IncSearch" -- 高亮组名

-- clear = true：重复 source 本文件不会累积重复的自动命令
local augroup = vim.api.nvim_create_augroup("custom_yank_highlight", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = HIGHLIGHT_GROUP, timeout = HIGHLIGHT_TIMEOUT })
  end,
})
