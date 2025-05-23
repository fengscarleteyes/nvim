-- stylua: ignore start
return {
  -- Fittencode keymaps
  { "<C-]>",     mode = { "i" }, function() require("fittencode").accept_all_suggestions() end, desc = "Fittencode accept all suggestions" },
  { "<C-e>",     mode = { "i" }, function() require("fittencode").dismiss_suggestions()    end, desc = "Fittencode dismiss suggestions"    },
  { "<C-Right>", mode = { "i" }, function() require("fittencode").accept_word()            end, desc = "Fittencode accept word"            },
  { "<C-Down>",  mode = { "i" }, function() require("fittencode").accept_line()            end, desc = "Fittencode accept libe"            },
  { "<C-Left>",  mode = { "i" }, function() require("fittencode").revoke_word()            end, desc = "Fittencode revoke word"            },
  { "<C-Up>",    mode = { "i" }, function() require("fittencode").revoke_line()            end, desc = "Fittencode revoke libe"            },

  -- Editor keymaps
  { "<C-CR>", mode = { "i" }, "<C-o>o", desc = "new line" },
  { "<C-h>",  mode = { "i" }, "<C-o>h", desc = "Left"     },
  { "<C-l>",  mode = { "i" }, "<C-o>l", desc = "Right"    },
  { "<C-k>",  mode = { "i" }, "<C-o>k", desc = "Up"       },
  { "<C-j>",  mode = { "i" }, "<C-o>j", desc = "Down"     },

  { "<A-j>", mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
  { "<A-J>", mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "<A-r>", mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "<A-R>", mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<A-g>", mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash

  { "<A-t>", mode = { "n", "t" }, "<Cmd>ToggleTerm<CR>", desc = "Toggle Terminal"                               },
  { "<A-b>", mode = { "n"      }, "<Cmd>BufferList<CR>", desc = "BufferList",     noremap = true, silent = true },
}
-- stylua: ignore end
