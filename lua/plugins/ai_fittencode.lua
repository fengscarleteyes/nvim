return {
  "luozhiya/fittencode.nvim",
  -- enabled = function()
  --   if vim.fn.has("win32") == 1 then
  --     return true
  --   elseif vim.fn.has("unix") == 1 then
  --     return false
  --   end
  -- end,
  -- enabled = true,
  enabled = false,
  config = function()
    require("noice").notify("load fitten")
    -- require("noice").notify
    require("fittencode").setup()
  end,
}
