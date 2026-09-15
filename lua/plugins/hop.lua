vim.pack.add({
  { src = "https://github.com/smoka7/hop.nvim" },
})

require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
-- require("hop").setup({ keys = "etovxqpdygfblzhckisuran", match_mappings = { "fa", "zh", "zh_sc" } })

-- place this in one of your configuration file(s)
-- local hop = require("hop")
-- local directions = require("hop.hint").HintDirection
-- vim.keymap.set("", "<A-f>", function()
--   hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
-- end, { remap = true })
-- vim.keymap.set("", "<A-F>", function()
--   hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
-- end, { remap = true })
-- vim.keymap.set("", "<A-t>", function()
--   hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false, hint_offset = -1 })
-- end, { remap = true })
-- vim.keymap.set("", "<A-T>", function()
--   hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false, hint_offset = 1 })
-- end, { remap = true })

local hop = require("hop")
vim.keymap.set("", "<A-f>", function()
  hop.hint_char1()
  -- hop.hint_char2()
end, { remap = true })
