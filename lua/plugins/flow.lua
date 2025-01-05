return {
  "0xstepit/flow.nvim",
  lazy = false,
  priority = 1000,
  -- tag = "v2.0.1",
  opts = {},
  config = function()
    require("flow").setup({})
    vim.cmd("colorscheme flow")
  end,
}
