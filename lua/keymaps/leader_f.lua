local neotree_cmd_filesystem =
  [[<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>]]

--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fF", mode = { "n" }, neotree_cmd_filesystem,                                       desc = "Filesystem neotree" },
  { "<leader>fo", mode = { "n" }, function() require("oil").toggle_float()                 end, desc = "Filesystem oil"     },
  { "<leader>fn", mode = { "n" }, function() require("telescope").extensions.nerdy.nerdy() end, desc = "find nerd"          },
  { "<leader>ff", mode = { "n" }, function() require("telescope.builtin").find_files()     end, desc = "find files"         },
  { "<leader>fb", mode = { "n" }, function() require("telescope.builtin").buffers()        end, desc = "buffers"            },
  { "<leader>fg", mode = { "n" }, function() require("telescope.builtin").live_grep()      end, desc = "live grep"          },
  { "<leader>fh", mode = { "n" }, function() require("telescope.builtin").help_tags()      end, desc = "help tags"          },
  { "<leader>ft", mode = { "n" }, "<Cmd>TodoTelescope<CR>",                                     desc = "TodoTelescope"      },
  }
-- stylua: ignore end
