local neotree_cmd_filesystem =
  [[<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>]]

--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fn", mode = { "n"      }, neotree_cmd_filesystem,                         desc = "Filesystem neotree" },
  { "<leader>ff", mode = { "n"      }, "<Cmd>FzfLua files<CR>",                        desc = "find files"         },
  { "<leader>fc", mode = { "n"      }, "<Cmd>FzfLua colorschemes<CR>",                 desc = "find colorschemes"  },
  { "<leader>fg", mode = { "n"      }, "<Cmd>FzfLua live_grep<CR>",                    desc = "live grep"          },
  { "<leader>fh", mode = { "n"      }, "<Cmd>FzfLua helptags<CR>",                     desc = "help tags"          },
  { "<leader>ft", mode = { "n"      }, "<Cmd>TodoFzfLua<CR>",                          desc = "TodoFzfLua"         },
  { "<leader>fr", mode = { "n", "x" }, "<Cmd>RipSubstitute<CR>",                       desc = "rip substitute"     },
  }
-- stylua: ignore end
