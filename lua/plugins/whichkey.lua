-- https://github.com/folke/which-key.nvim

return {
  "folke/which-key.nvim",
  dependencies = { { "echasnovski/mini.icons", version = "*" }, { "nvim-tree/nvim-web-devicons", opts = {} } },
  event = "VeryLazy",
  opts = {
    win = {
      no_overlap = true,
      width = -2,
      -- width = 50,
      height = { min = 5, max = 25 },
      col = 1,
      -- row = math.huge,
      -- border = "single",
      border = "double",
      padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      title = false,
      title_pos = "center",
      zindex = 1000,
      -- Additional vim.wo and vim.bo options
      bo = {},
      wo = {
        -- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    icons = { rules = false },
    layout = {
      width = { min = 20 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
    },
    plugins = {
      marks = false,
      spelling = false,
    },
    -- disable WhichKey for certain buf types and file types.
    disable = {
      -- ft = { "norg" },
      -- bt = {},
    },
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    require("keymaps")
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
