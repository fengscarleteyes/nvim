-- stylua: ignore start
return {
  { "<C-CR>", mode = { "i" },           "<C-o>o",                                            desc = "new line"            },
  { "<C-h>",  mode = { "i" },           "<C-o>h",                                            desc = "Left"                },
  { "<C-l>",  mode = { "i" },           "<C-o>l",                                            desc = "Right"               },
  { "<C-k>",  mode = { "i" },           "<C-o>k",                                            desc = "Up"                  },
  { "<C-j>",  mode = { "i" },           "<C-o>j",                                            desc = "Down"                },
  { "<A-t>",  mode = { "n", "t" },      function() require("FTerm").toggle()            end, desc = "FTerm toggle"        },
  -- TODO: move this to leader keys?
  { "s",      mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
  { "S",      mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "r",      mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "R",      mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<c-s>",  mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash
}
-- stylua: ignore end
