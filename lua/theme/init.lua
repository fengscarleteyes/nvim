-- colorscheme

return {
  {
    "kuri-sun/yoda.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme("yoda")
    end,
  },
  {
    "wurli/cobalt.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    -- config = function()
    --   vim.cmd.colorscheme("cobalt")
    -- end,
  },
  {
    "uhs-robert/oasis.nvim",
    config = function()
      -- vim.cmd.colorscheme("oasis") -- or use a variant like ("oasis_desert")
      -- vim.cmd.colorscheme("oasis-lagoon")
      -- vim.cmd.colorscheme("oasis-starlight")
    end,
  },
  {
    "0xstepit/flow.nvim",
    lazy = false,
    priority = 1000,
    -- tag = "vX.0.0",
    opts = {
      theme = {
        style = "dark", --  "dark" | "light"
        contrast = "high", -- "default" | "high"
        transparent = false, -- true | false
      },
    },
    -- config = function(_, opts)
    --   require("flow").setup(opts)
    --   vim.cmd("colorscheme flow")
    -- end,
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
