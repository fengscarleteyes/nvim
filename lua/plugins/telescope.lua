return {
  "nvim-telescope/telescope.nvim",
  -- enabled = false,
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  opts = {
    defaults = {
      treesitter = true,
      -- treesitter = false,
      -- prompt_prefix = '  ',
      -- selection_caret = '  ',
      mappings = false,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
