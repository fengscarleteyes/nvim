return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function(_, opts)
    require('which-key').setup(opts)
    require('config.keys')
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show()
        -- require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
