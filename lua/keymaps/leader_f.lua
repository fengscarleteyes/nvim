--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fF", mode = { "n" }, "<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Filesystem"    },
  { "<leader>fo", mode = { "n" }, function() require("oil").toggle_float()                 end,                             desc = "Oil       | toggle"      },
  { "<leader>fn", mode = { "n" }, function() require("telescope").extensions.nerdy.nerdy() end,                             desc = "telescope | find nerd"   },
  { "<leader>ff", mode = { "n" }, function() require("telescope.builtin").find_files()     end,                             desc = "telescope | find files"  },
  { "<leader>fb", mode = { "n" }, function() require("telescope.builtin").buffers()        end,                             desc = "telescope | buffers"     },
  { "<leader>fg", mode = { "n" }, function() require("telescope.builtin").live_grep()      end,                             desc = "telescope | live grep"   },
  { "<leader>fh", mode = { "n" }, function() require("telescope.builtin").help_tags()      end,                             desc = "telescope | help tags"   },
  }
-- stylua: ignore end
