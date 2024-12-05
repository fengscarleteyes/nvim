return {
  "luozhiya/fittencode.nvim",
  -- enabled = function()
  --   if vim.fn.has("win32") == 1 then
  --     return true
  --   elseif vim.fn.has("unix") == 1 then
  --     return false
  --   end
  -- end,
  config = function()
    require("fittencode").setup({ completion_mode = "inline" })
  end,
}
