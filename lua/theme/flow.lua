return {
  "0xstepit/flow.nvim",
  lazy = false,
  priority = 1000,
  -- tag = "v2.0.1",
  opts = {
    theme = {
      style = "dark", --  "dark" | "light"
      contrast = "high", -- "default" | "high"
      transparent = false, -- true | false
    },
    colors = {
      mode = "dark", -- "default" | "dark" | "light"
      fluo = "pink", -- "pink" | "cyan" | "yellow" | "orange" | "green"
      custom = {
        saturation = 50, -- "" | string representing an integer between 0 and 100
        light = 50, -- "" | string representing an integer between 0 and 100
      },
    },
    ui = {
      borders = "inverse", -- "theme" | "inverse" | "fluo" | "none"
      aggressive_spell = false,
    },
  },
  config = function(_, opts)
    require("flow").setup(opts)
    vim.cmd("colorscheme flow")
  end,
}
