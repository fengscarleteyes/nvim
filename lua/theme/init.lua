-- colorscheme

return {
  {
    "y3owk1n/base16-pro-max.nvim",
    -- enabled = false,
    config = function()
      require("base16-pro-max").setup({
        colors = {
          base00 = "#24273a",
          base01 = "#1e2030",
          base02 = "#363a4f",
          base03 = "#494d64",
          base04 = "#5b6078",
          base05 = "#cad3f5",
          base06 = "#f4dbd6",
          base07 = "#b7bdf8",
          base08 = "#ed8796",
          base09 = "#f5a97f",
          base0A = "#eed49f",
          base0B = "#a6da95",
          base0C = "#8bd5ca",
          base0D = "#8aadf4",
          base0E = "#c6a0f6",
          base0F = "#f0c6c6",
        },
        -- Plugin integrations
        plugins = {
          enable_all = false, -- Enable all supported plugins
        },
      })
      vim.cmd.colorscheme("base16-pro-max")
    end,
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    -- config = function()
    --   vim.cmd([[colorscheme kanagawa-paper]])
    -- end,
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
