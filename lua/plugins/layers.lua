-- TODO:
-- DEBUG_MODE = Layers.mode.new() -- global, accessible from anywhere
-- DEBUG_MODE:auto_show_help()
-- DEBUG_MODE:keymaps({
--   n = {
--     {
--       "s",
--       function()
--         vim.notify("s")
--       end,
--       { desc = "s kb" },
--     },
--     {
--       "c",
--       function()
--         vim.notify("c")
--       end,
--       { desc = "c kb" },
--     },
--     {
--       "<esc>",
--       function()
--         DEBUG_MODE:deactivate()
--       end,
--       { desc = "exit" },
--     },
--   },
-- })
-- DEBUG_MODE:activate()

return {
  "debugloop/layers.nvim",
  opts = {}, -- see :help Layers.config
}
-- https://github.com/debugloop/layers.nvim
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md
