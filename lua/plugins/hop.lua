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
  -- 传空表：hint_char1 的 ---@param opts Options 是必填参数，不传会被 lua_ls 判成缺参数。
  -- 空表与不传完全等价（内部 override_opts 用 opts or {} 并逐字段回落到 hop 默认值）。
  -- 但 hop 上游把 Options.direction 标成了必填字段、运行时却允许缺省（缺省 = 光标前后都提示），
  -- 所以这里显式抑制 missing-fields 这一条；若只想要"光标之后"，用上面注释里的官方写法
  -- { direction = directions.AFTER_CURSOR }，但那会改变提示范围，属于行为变更。
  ---@diagnostic disable-next-line: missing-fields
  hop.hint_char1({})
  -- hop.hint_char2()
end, { remap = true })
