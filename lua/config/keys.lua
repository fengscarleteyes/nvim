local wk = require("which-key")

wk.add({ { "<leader>", group = "leader keys" } })

--stylua: ignore start
wk.add({
  { "<leader>n", group = "Noice" }, -- group
  { "<leader>nn", mode = { "n" }, function() require("noice").cmd("dismiss")   end, desc = "noice dismiss"   },
  { "<leader>nh", mode = { "n" }, function() require("noice").cmd("history")   end, desc = "noice history"   },
  { "<leader>nl", mode = { "n" }, function() require("noice").cmd("last"   )   end, desc = "noice last"      },
  { "<leader>nd", mode = { "n" }, function() require("noice").cmd("disable")   end, desc = "noice disable"   },
  { "<leader>ne", mode = { "n" }, function() require("noice").cmd("enable" )   end, desc = "noice enable"    },
  { "<leader>nt", mode = { "n" }, function() require("noice").cmd("telescope") end, desc = "noice telescope" },
  { "<leader>nE", mode = { "n" }, function() require("noice").cmd("erroes")    end, desc = "noice errors"    },
  { "<leader>ns", mode = { "n" }, function() require("noice").cmd("stats"  )   end, desc = "noice stats"     },

  { "<A-t>",     mode = { "n", "t" }, function() require("FTerm").toggle() end, desc = "FTerm toggle"  },
  { "<leader>w", mode = { "n"      }, "<cmd>bdelete<CR>",                       desc = "Buffer Delete" },

  { "s",     mode =  { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
  { "S",     mode =  { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
  { "r",     mode =  { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "R",     mode =  { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
  { "<c-s>", mode =  { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash


  { "<leader>b", group = "buffer" },
  { "<leader>bb", mode = { "n" }, ":lua Snacks.bufdelete()<CR>",        desc = "Snacks delete Buffer"        },
  { "<leader>ba", mode = { "n" }, ":lua Snacks.bufdelete.all()<CR>",    desc = "Snacks delete Buffer All"    },
  { "<leader>bd", mode = { "n" }, ":lua Snacks.bufdelete.delete()<CR>", desc = "Snacks delete Buffer delete" },
  { "<leader>bo", mode = { "n" }, ":lua Snacks.bufdelete.other()<CR>",  desc = "Snacks delete Buffer other"  },

  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fB", mode = { "n" }, "<cmd>Neotree source=buffers    reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Buffers"    },
  { "<leader>fG", mode = { "n" }, "<cmd>Neotree source=git_status reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Git Status" },
  { "<leader>fF", mode = { "n" }, "<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Filesystem" },
  { "<leader>fo", mode = { "n" }, function() require("oil").toggle_float()                 end, desc = "Oil       | toggle"     },
  { "<leader>fn", mode = { "n" }, function() require("telescope").extensions.nerdy.nerdy() end, desc = "telescope | find nerd"  },
  { "<leader>ff", mode = { "n" }, function() require("telescope.builtin").find_files()     end, desc = "telescope | find files" },
  { "<leader>fb", mode = { "n" }, function() require("telescope.builtin").buffers()        end, desc = "telescope | buffers"    },
  { "<leader>fg", mode = { "n" }, function() require("telescope.builtin").live_grep()      end, desc = "telescope | live grep"  },
  { "<leader>fh", mode = { "n" }, function() require("telescope.builtin").help_tags()      end, desc = "telescope | help tags"  },

  { "<leader>r", group = "RunCode" },
  { "<leader>rr",  mode = { "n" }, "<Cmd>RunCode<CR>",        desc = "RunCode",     noremap = true, silent = false },
  { "<leader>rf",  mode = { "n" }, "<Cmd>RunFile tab<CR>",    desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp",  mode = { "n" }, "<Cmd>RunProject tab<CR>", desc = "RunProject",  noremap = true, silent = false },
  { "<leader>rc",  mode = { "n" }, "<Cmd>RunClose<CR>",       desc = "RunClose",    noremap = true, silent = false },
  { "<leader>ref", mode = { "n" }, "<Cmd>CRFiletype<CR>",     desc = "CRFiletype",  noremap = true, silent = false },
  { "<leader>rep", mode = { "n" }, "<Cmd>CRProjects<CR>",     desc = "CRProjects",  noremap = true, silent = false },

  { "<leader>s", group = "Surround" },
  { "<leader>ss", mode = { "n" }, "<Plug>(nvim-surround-normal-cur)",      desc = "surround normal cur",      noremap = true, silent = false },
  { "<leader>sS", mode = { "n" }, "<Plug>(nvim-surround-normal)",          desc = "surround normal",          noremap = true, silent = false },
  { "<leader>sd", mode = { "n" }, "<Plug>(nvim-surround-delete)",          desc = "surround delete",          noremap = true, silent = false },
  { "<leader>sl", mode = { "n" }, "<Plug>(nvim-surround-normal-cur-line)", desc = "surround normal cur line", noremap = true, silent = false },
  { "<leader>sL", mode = { "n" }, "<Plug>(nvim-surround-normal-line)",     desc = "surround normal line",     noremap = true, silent = false },
  { "<leader>sr", mode = { "n" }, "<Plug>(nvim-surround-change)",          desc = "surround change",          noremap = true, silent = false },
  { "<leader>sR", mode = { "n" }, "<Plug>(nvim-surround-change-line)",     desc = "surround change line",     noremap = true, silent = false },
  { "<leader>sv", mode = { "x" }, "<Plug>(nvim-surround-visual-line)",     desc = "surround visual line)",    noremap = true, silent = false },
  { "<leader>sV", mode = { "x" }, "<Plug>(nvim-surround-visual)",          desc = "surround visual",          noremap = true, silent = false },
  -- <Plug>(nvim-surround-insert)
  -- <Plug>(nvim-surround-insert-line)

  -- TODO: ...
  -- keys = {
  --   {
  --     "<leader>xx",
  --     "<cmd>Trouble diagnostics toggle<cr>",
  --     desc = "Diagnostics (Trouble)",
  --   },
  --   {
  --     "<leader>xX",
  --     "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  --     desc = "Buffer Diagnostics (Trouble)",
  --   },
  --   {
  --     "<leader>cs",
  --     "<cmd>Trouble symbols toggle focus=false<cr>",
  --     desc = "Symbols (Trouble)",
  --   },
  --   {
  --     "<leader>cl",
  --     "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  --     desc = "LSP Definitions / references / ... (Trouble)",
  --   },
  --   {
  --     "<leader>xL",
  --     "<cmd>Trouble loclist toggle<cr>",
  --     desc = "Location List (Trouble)",
  --   },
  --   {
  --     "<leader>xQ",
  --     "<cmd>Trouble qflist toggle<cr>",
  --     desc = "Quickfix List (Trouble)",
  --   },
  -- },

  -- :TodoTelescope cwd=~/projects/foobar
  -- :TodoTelescope keywords=TODO,FIX
  -- Trouble todo filter = {tag = {TODO,FIX,FIXME}}
  -- vim.keymap.set("n", "]t", function()
  --   require("todo-comments").jump_next()
  -- end, { desc = "Next todo comment" })

  -- vim.keymap.set("n", "[t", function()
  --   require("todo-comments").jump_prev()
  -- end, { desc = "Previous todo comment" })

  -- -- You can also specify a list of valid jump keywords

  -- vim.keymap.set("n", "]t", function()
  --   require("todo-comments").jump_next({keywords = { "ERROR", "WARNING" }})
  -- end, { desc = "Next error/warning todo comment" })
})
-- stylua: ignore end
