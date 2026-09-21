-- ============================================================
-- 历史 / 备选映射（本目录不会被加载）
-- ------------------------------------------------------------
-- lua/keymaps.lua 的 glob 是 lua/keymaps/*.lua，不匹配子目录，
-- 所以放在 bak/ 里的本文件不会生效，仅作参考。
-- 需要启用其中的映射时：取消注释，并把本文件移到 lua/keymaps/ 下。
-- 注意：下面引用的插件（fittencode / notify / scissors）当前并未安装，
--       启用前先确认插件可用，否则 require 会报 "module not found"。
-- ============================================================

-- 插件更新面板（vim.pack.update）
-- vim.keymap.set("n", "<leader>pu", function()
--   vim.pack.update()
-- end, { silent = true, desc = "Vim pack update" })

-- Fittencode：接受全部建议
-- vim.keymap.set("i", "<C-]>", function()
--   require("fittencode").accept_all_suggestions()
-- end, { silent = true, desc = "Fittencode accept all suggestions" })

-- 通知：关闭全部通知 / 打开通知历史（当前用的是 notifier.nvim）
-- vim.keymap.set("n", "<leader>nn", function()
--   require("notify").dismiss({ pending = true, silent = true })
-- end, { silent = true, desc = "Hide notifications" })
-- vim.keymap.set("n", "<leader>nh", function()
--   require("notify.integrations").pick()
-- end, { silent = true, desc = "show notifications history" })

-- 代码片段（scissors）：编辑 / 新增片段
-- vim.keymap.set("n", "<leader>se", function()
--   require("scissors").editSnippet()
-- end, { silent = true, desc = "Snippet: Edit" })
-- 可视模式下会把选中内容作为片段主体
-- vim.keymap.set({ "n", "x" }, "<leader>sa", function()
--   require("scissors").addNewSnippet()
-- end, { silent = true, desc = "Snippet: Add" })
