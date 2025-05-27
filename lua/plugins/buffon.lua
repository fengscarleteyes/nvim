-- https://github.com/francescarpi/buffon.nvim

return {
  {
    "francescarpi/buffon.nvim",
    branch = "main",
    opts = {
      cyclic_navigation = true,
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
  },
}

-- TODO: add keybindings for cyclic navigation
