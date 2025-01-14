local neotree_cmd_filesystem =
  [[<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>]]

--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fF", mode = { "n"      }, neotree_cmd_filesystem,                         desc = "Filesystem neotree" },
  { "<leader>fo", mode = { "n"      }, function() require("oil").toggle_float() end,   desc = "Filesystem oil"     },
  { "<leader>ff", mode = { "n"      }, "<Cmd>FzfLua files<CR>",                        desc = "find files"         },
  { "<leader>fb", mode = { "n"      }, "<Cmd>FzfLua buffers<CR>",                      desc = "buffers"            },
  { "<leader>fg", mode = { "n"      }, "<Cmd>FzfLua grep<CR>",                         desc = "live grep"          },
  { "<leader>fh", mode = { "n"      }, "<Cmd>FzfLua helptags<CR>",                     desc = "help tags"          },
  { "<leader>ft", mode = { "n"      }, "<Cmd>TodoTelescope<CR>",                       desc = "TodoTelescope"      },
  { "<leader>fs", mode = { "n", "x" }, function() require("rip-substitute").sub() end, desc = " rip substitute"   },
  }
-- stylua: ignore end
