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
  { "<A-s>", mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "<A-f>", mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "<A-r>", mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<A-g>", mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash

  -- { "<A-t>",      mode = { "n", "t" }, "<Cmd>ToggleTerm<CR>",                                             desc = "Toggle Terminal"                   },
  { "<A-1>", mode = { "n" }, "<Cmd>BufferGoto 1<CR>", desc = "BufferGoto 1", noremap = true, silent = true },
  { "<A-2>", mode = { "n" }, "<Cmd>BufferGoto 2<CR>", desc = "BufferGoto 2", noremap = true, silent = true },
  { "<A-3>", mode = { "n" }, "<Cmd>BufferGoto 3<CR>", desc = "BufferGoto 3", noremap = true, silent = true },
  { "<A-4>", mode = { "n" }, "<Cmd>BufferGoto 4<CR>", desc = "BufferGoto 4", noremap = true, silent = true },
  { "<A-5>", mode = { "n" }, "<Cmd>BufferGoto 5<CR>", desc = "BufferGoto 5", noremap = true, silent = true },
  { "<A-6>", mode = { "n" }, "<Cmd>BufferGoto 6<CR>", desc = "BufferGoto 6", noremap = true, silent = true },
  { "<A-7>", mode = { "n" }, "<Cmd>BufferGoto 7<CR>", desc = "BufferGoto 7", noremap = true, silent = true },
  { "<A-8>", mode = { "n" }, "<Cmd>BufferGoto 8<CR>", desc = "BufferGoto 8", noremap = true, silent = true },
  { "<A-9>", mode = { "n" }, "<Cmd>BufferGoto 9<CR>", desc = "BufferGoto 9", noremap = true, silent = true },
  { "<A-0>", mode = { "n" }, "<Cmd>BufferLast<CR>",   desc = "Buffer Last",  noremap = true, silent = true },
}
-- stylua: ignore end
