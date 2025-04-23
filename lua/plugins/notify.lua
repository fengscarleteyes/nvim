-- https://github.com/rcarriga/nvim-notify

return {
  "rcarriga/nvim-notify",
  -- config = true,
  config = function()
    vim.notify = require("notify")
  end,
}
