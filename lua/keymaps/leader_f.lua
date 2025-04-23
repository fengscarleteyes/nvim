--stylua: ignore start
return {
  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fe", mode = { "n"      }, "<cmd>Neotree filesystem toggle<CR>",           desc = "Filesystem neotree" },
  { "<leader>ff", mode = { "n"      }, "<Cmd>FzfLua files<CR>",                        desc = "find files"         },
  { "<leader>fc", mode = { "n"      }, "<Cmd>FzfLua colorschemes<CR>",                 desc = "find colorschemes"  },
  { "<leader>fg", mode = { "n"      }, "<Cmd>FzfLua live_grep<CR>",                    desc = "live grep"          },
  { "<leader>fh", mode = { "n"      }, "<Cmd>FzfLua helptags<CR>",                     desc = "help tags"          },
  { "<leader>ft", mode = { "n"      }, "<Cmd>TodoFzfLua<CR>",                          desc = "TodoFzfLua"         },
  }
-- stylua: ignore end
