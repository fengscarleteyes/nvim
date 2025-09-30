-- https://github.com/y3owk1n/notifier.nvim

return {
  "y3owk1n/notifier.nvim",
  -- lazy = false,
  config = function()
    -- Basic setup with defaults, these are all you need to get started, unless you want to fine-tune the details
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

    -- Or you can try out the demo that we prepared to see what notifier.nvim can do
    -- require("notifier.demo").run_demo()
  end,
}
