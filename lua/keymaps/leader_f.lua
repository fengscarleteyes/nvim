local neotree_cmd_filesystem =
  [[<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>]]

--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fF", mode = { "n"      }, neotree_cmd_filesystem,                                       desc = "Filesystem neotree" },
  { "<leader>fo", mode = { "n"      }, function() require("oil").toggle_float()                 end, desc = "Filesystem oil"     },
  { "<leader>fn", mode = { "n"      }, function() require("telescope").extensions.nerdy.nerdy() end, desc = "find nerd"          },
  { "<leader>fd", mode = { "n"      }, function() require('trouble.sources.telescope').open()   end, desc = "find trouble"       },
  { "<leader>ff", mode = { "n"      }, function() require("telescope.builtin").find_files()     end, desc = "find files"         },
  { "<leader>fb", mode = { "n"      }, function() require("telescope.builtin").buffers()        end, desc = "buffers"            },
  { "<leader>fg", mode = { "n"      }, function() require("telescope.builtin").live_grep()      end, desc = "live grep"          },
  { "<leader>fh", mode = { "n"      }, function() require("telescope.builtin").help_tags()      end, desc = "help tags"          },
  { "<leader>ft", mode = { "n"      }, "<Cmd>TodoTelescope<CR>",                                     desc = "TodoTelescope"      },
  { "<leader>fs", mode = { "n", "x" }, function() require("rip-substitute").sub()               end, desc = " rip substitute"   },

  { "<leader>fj", mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
  { "<leader>fJ", mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "<leader>fr", mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "<leader>fR", mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<c-s>",      mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash
  }
-- stylua: ignore end
