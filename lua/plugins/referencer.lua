-- https://github.com/romus204/referencer.nvim

return {
  "romus204/referencer.nvim",
  config = function()
    require("referencer").setup({
      enable = true,
      format = "   %d",
      color = "#FFA500",
    })
  end,
}
