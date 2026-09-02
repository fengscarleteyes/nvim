vim.pack.add({
  "https://github.com/y3owk1n/notifier.nvim",
})

require("notifier").setup({
  border = "rounded",
  default_group = "top-right",
  animation = {
    enabled = true,
  },
})
-- Now use enhanced vim.notify
-- vim.notify("Hello, World!")
-- vim.notify("Warning message", vim.log.levels.WARN)
-- vim.notify("Error occurred", vim.log.levels.ERROR)

