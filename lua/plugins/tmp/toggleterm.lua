-- https://github.com/akinsho/toggleterm.nvim

return {
  "akinsho/toggleterm.nvim",
  enabled = false,
  version = "*",
  opts = {
    -- shell = vim.o.shell,
    -- shell = "bash",
    highlights = {
      Normal = {
        guibg = "none",
      },
      NormalFloat = {
        link = "Normal",
      },
      FloatBorder = {
        guifg = "#00FF00",
        guibg = "none",
      },
    },
    float_opts = {
      border = "double",
    },
    direction = "float",
  },
}
