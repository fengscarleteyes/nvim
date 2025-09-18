return {
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd([[colorscheme kanagawa-paper]])
    end,
  },

  {
    "rmehri01/onenord.nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { transparent = vim.g.transparent_enabled },
    -- config = function(_, opts)
    -- require("tokyonight").setup(opts)
    -- vim.cmd("colorscheme tokyonight-night")
    -- vim.cmd("colorscheme tokyonight-moon")
    -- vim.cmd("colorscheme tokyonight-storm")
    -- vim.cmd("colorscheme tokyonight-day")
    -- end,
  },
}
