-- https://github.com/rcarriga/nvim-notify
return {
  "rcarriga/nvim-notify",
  opts = { background_colour = "#000000", render = "compact" },
  config = function(_, opts)
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
