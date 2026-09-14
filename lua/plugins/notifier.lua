vim.pack.add({
  "https://github.com/y3owk1n/notifier.nvim",
})

require("notifier").setup({
  border = "rounded",
  default_group = "top-right",
  group_configs = {
    ["top-right"] = {
      anchor = "NE",
      row = function() return 3 end, -- Leave more space from bottom
      col = function() return vim.o.columns - 1 end,
      winblend = 20, -- Semi-transparent
    }
  },
  animation = {
    enabled = true,
  },
})
-- Now use enhanced vim.notify
-- vim.notify("Hello, World!")
-- vim.notify("Warning message", vim.log.levels.WARN)
-- vim.notify("Error occurred", vim.log.levels.ERROR)
