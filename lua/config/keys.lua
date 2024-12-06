local wk = require("which-key")

local m = {}

m.x__ = { "x" }
m.o__ = { "o" }
m.ox_ = { "o", "x" }
m.c__ = { "c" }
m.n__ = { "n" }
m.nt_ = { "n", "t" }
m.nxo = { "n", "x", "o" }

-- stylua: ignore start
local use_flash             = require("flash"            )
local use_fterm             = require("FTerm"            )
local use_noice             = require("noice"            )
local use_oil               = require("oil"              )
local use_telescope         = require("telescope"        )
local use_telescope_builtin = require("telescope.builtin")
--stylua: ignore end

-- stylua: ignore start
wk.add({
  { "<leader>", group = "leader keys" }, -- group

  { "<leader>n", group = "Noice" }, -- group
  { "<leader>nn", mode = m.n__, function() use_noice.cmd("dismiss"  )   end, desc = "noice dismiss"   },
  { "<leader>nh", mode = m.n__, function() use_noice.cmd("history"  )   end, desc = "noice history"   },
  { "<leader>nl", mode = m.n__, function() use_noice.cmd("last"     )   end, desc = "noice last"      },
  { "<leader>nd", mode = m.n__, function() use_noice.cmd("disable"  )   end, desc = "noice disable"   },
  { "<leader>ne", mode = m.n__, function() use_noice.cmd("enable"   )   end, desc = "noice enable"    },
  { "<leader>nt", mode = m.n__, function() use_noice.cmd("telescope")   end, desc = "noice telescope" },
  { "<leader>nE", mode = m.n__, function() use_noice.cmd("errors"   )   end, desc = "noice errors"    },
  { "<leader>ns", mode = m.n__, function() use_noice.cmd("stats"    )   end, desc = "noice stats"     },

  { "<A-t>", mode = m.nt_, function() use_fterm.toggle() end, desc = "FTerm toggle" },
  { "<leader>w", mode = m.n__, "<cmd>bd<CR>", desc = "Buffer Delete" },

  { "s",     mode = m.nxo, function() use_flash.jump()              end, desc = "Flash"               },
  { "S",     mode = m.nxo, function() use_flash.treesitter()        end, desc = "Flash Treesitter"    },
  { "r",     mode = m.o__, function() use_flash.remote()            end, desc = "Remote Flash"        }, -- in omap"y, d, c ..."
  { "R",     mode = m.ox_, function() use_flash.treesitter_search() end, desc = "Treesitter Search"   },
  { "<c-s>", mode = m.c__, function() use_flash.toggle()            end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash

  { "<leader>t", group = "File | Tree" }, -- group
  { "<leader>tb", mode = m.n__, "<cmd>Neotree source=buffers    reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Buffers"    },
  { "<leader>tg", mode = m.n__, "<cmd>Neotree source=git_status reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Git Status" },
  { "<leader>tf", mode = m.n__, "<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Filesystem" },

  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fo", mode = m.n__, function() use_oil.toggle_float()                 end, desc = "Oil toggle"           },
  { "<leader>fn", mode = m.n__, function() use_telescope.extensions.nerdy.nerdy() end, desc = "telescope find nerd"  },
  { "<leader>ff", mode = m.n__, function() use_telescope_builtin.find_files()     end, desc = "telescope find files" },
  { "<leader>fb", mode = m.n__, function() use_telescope_builtin.buffers()        end, desc = "telescope buffers"    },
  { "<leader>fg", mode = m.n__, function() use_telescope_builtin.live_grep()      end, desc = "telescope live grep"  },
  { "<leader>fh", mode = m.n__, function() use_telescope_builtin.help_tags()      end, desc = "telescope help tags"  },

  { "<leader>r", group = "RunCode" },
  { "<leader>rr",  mode = m.n__, "<Cmd>RunCode<CR>",        desc = "RunCode",     noremap = true, silent = false },
  { "<leader>rf",  mode = m.n__, "<Cmd>RunFile tab<CR>",    desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp",  mode = m.n__, "<Cmd>RunProject tab<CR>", desc = "RunProject",  noremap = true, silent = false },
  { "<leader>rc",  mode = m.n__, "<Cmd>RunClose<CR>",       desc = "RunClose",    noremap = true, silent = false },
  { "<leader>ref", mode = m.n__, "<Cmd>CRFiletype<CR>",     desc = "CRFiletype",  noremap = true, silent = false },
  { "<leader>rep", mode = m.n__, "<Cmd>CRProjects<CR>",     desc = "CRProjects",  noremap = true, silent = false },

  { "<leader>s", group = "Surround" },
  { "<leader>ss", mode = m.n__, "<Plug>(nvim-surround-normal-cur)",      desc = "surround normal cur",      noremap = true, silent = false },
  { "<leader>sS", mode = m.n__, "<Plug>(nvim-surround-normal)",          desc = "surround normal",          noremap = true, silent = false },
  { "<leader>sd", mode = m.n__, "<Plug>(nvim-surround-delete)",          desc = "surround delete",          noremap = true, silent = false },
  { "<leader>sl", mode = m.n__, "<Plug>(nvim-surround-normal-cur-line)", desc = "surround normal cur line", noremap = true, silent = false },
  { "<leader>sL", mode = m.n__, "<Plug>(nvim-surround-normal-line)",     desc = "surround normal line",     noremap = true, silent = false },
  { "<leader>sr", mode = m.n__, "<Plug>(nvim-surround-change)",          desc = "surround change",          noremap = true, silent = false },
  { "<leader>sR", mode = m.n__, "<Plug>(nvim-surround-change-line)",     desc = "surround change line",     noremap = true, silent = false },
  { "<leader>sv", mode = m.x__, "<Plug>(nvim-surround-visual-line)",     desc = "surround visual line)",    noremap = true, silent = false },
  { "<leader>sV", mode = m.x__, "<Plug>(nvim-surround-visual)",          desc = "surround visual",          noremap = true, silent = false },
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
