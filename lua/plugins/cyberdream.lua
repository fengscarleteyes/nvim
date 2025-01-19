-- theme

return {
  "scottmckendry/cyberdream.nvim",
  -- enable = false,
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme cyberdream")
  end,
}
