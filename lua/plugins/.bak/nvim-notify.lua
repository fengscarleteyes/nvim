-- https://github.com/rcarriga/nvim-notify

return {
  "rcarriga/nvim-notify",
  enabled = false,
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
