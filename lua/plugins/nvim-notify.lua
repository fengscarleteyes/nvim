-- https://github.com/rcarriga/nvim-notify

return {
  "rcarriga/nvim-notify",
  config = function()
    require("notify").setup({
      merge_duplicates = true,
      stages = "fade_in_slide_out",
      background_colour = "FloatShadow",
      timeout = 3000,
      render = "minimal",
      max_width = 80,
    })
    vim.notify = require("notify")
  end,
}
