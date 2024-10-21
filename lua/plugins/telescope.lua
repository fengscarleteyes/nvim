return {
  "nvim-telescope/telescope.nvim",
  -- enabled = false,
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  opts = {
    defaults = {
      treesitter = true,
      mappings = false,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  -- stylua: ignore
  keys = {
    { '<F1>', mode = "n", function() require('telescope.builtin').buffers()    end, desc = "telescope buffers"    },
    { '<F2>', mode = "n", function() require('telescope.builtin').find_files() end, desc = "telescope find files" },
    { '<F3>', mode = "n", function() require('telescope.builtin').live_grep()  end, desc = "telescope live grep"  },
    { '<F4>', mode = "n", function() require('telescope.builtin').help_tags()  end, desc = "telescope help tags"  },
  },
}
