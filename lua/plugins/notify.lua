-- https://github.com/rcarriga/nvim-notify
return {
  "rcarriga/nvim-notify",
  -- enabled = false,
  opts = {
    background_colour = "#000000",
    -- render = "compact"
    stages = "slide",
  },
  config = function(_, opts)
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
