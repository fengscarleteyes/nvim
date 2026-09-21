-- ============================================================
-- 缩进参考线开关：<leader>it（blink.indent）
-- （由 lua/keymaps.lua 通过 :runtime! lua/keymaps/*.lua 加载）
-- ============================================================

vim.keymap.set("n", "<leader>it", function()
  local indent = require("blink.indent")
  indent.enable(not indent.is_enabled())
end, { silent = true, desc = "Toggle indent guides" })
