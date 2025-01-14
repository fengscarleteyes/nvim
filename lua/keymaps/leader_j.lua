--stylua: ignore start
return {
  { "<leader>jj", mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
  { "<leader>jJ", mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "<leader>jr", mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "<leader>jR", mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<c-s>",      mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash
  }
-- stylua: ignore end
