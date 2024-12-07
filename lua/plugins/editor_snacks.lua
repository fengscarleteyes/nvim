-- TODO: add handle enable & delete other plugin like Fterm,noice ...
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    dashboard = { enabled = true },
    bigfile = { enabled = true },
    notifier = { enabled = true },
    noitfy = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lazygit = { enabled = true },
  },
}
