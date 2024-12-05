local wk = require("which-key")
-- stylua: ignore start
wk.add({
  { "<leader>", group = "leader keys" }, -- group

  { "<leader><Space>", mode = "n", function() require("noice").cmd("dismiss") end, desc = "noice dismiss" },
  -- TODO: add noicedisable key and toggle enable
  --
  { "<A-t>", mode = { "t", "n" }, function() require("FTerm").toggle() end, desc = "FTerm toggle" },
  { "<leader>w", mode = "n", "<cmd>bd<CR>", desc = "Buffer Delete" },

  { "s", mode = { "n", "x", "o" }, function() require("lua.plugins.editor_flash").jump() end, desc = "Flash" },
  { "S", mode = { "n", "x", "o" }, function() require("lua.plugins.editor_flash").treesitter() end, desc = "Flash Treesitter" },
  { "r", mode = { "o" }, function() require("lua.plugins.editor_flash").remote() end, desc = "Remote Flash" }, -- in omap"y, d, c ..."
  { "R", mode = { "o", "x" }, function() require("lua.plugins.editor_flash").treesitter_search() end, desc = "Treesitter Search" },
  { "<c-s>", mode = { "c" },  function() require("lua.plugins.editor_flash").toggle() end, desc = "Toggle Flash Search" }, -- in "/" search mode toggle flash

  { "<leader>t", group = "File | Tree" }, -- group
  { "<leader>tb", mode = "n", "<cmd>Neotree source=buffers reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Buffers" },
  { "<leader>tg", mode = "n", "<cmd>Neotree source=git_status reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Git Status" },
  { "<leader>tf", mode = "n", "<cmd>Neotree source=filesystem reveal=true position=float action=focus toggle=true<CR>", desc = "NeoTree | Filesystem" },

  { "<leader>f", group = "File | Find" }, -- group
  { "<leader>fo", mode = "n", function() require("oil").toggle_float() end, desc = "Oil toggle" },
  { "<leader>fn", mode = "n", function() require("lua.plugins.editor_telescope").extensions.nerdy.nerdy() end, desc = "Oil toggle" },
  { "<leader>ff", mode = "n", function() require("telescope.builtin").find_files() end, desc = "telescope find files" },
  { "<leader>fb", mode = "n", function() require("telescope.builtin").buffers() end, desc = "telescope buffers" },
  { "<leader>fg", mode = "n", function() require("telescope.builtin").live_grep() end, desc = "telescope live grep" },
  { "<leader>fh", mode = "n", function() require("telescope.builtin").help_tags() end, desc = "telescope help tags" },

  { "<leader>r", group = "RunCode" },
  { "<leader>rr", mode = "n", "<Cmd>RunCode<CR>", desc = "RunCode", noremap = true, silent = false },
  { "<leader>rf", mode = "n", "<Cmd>RunFile tab<CR>", desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp", mode = "n", "<Cmd>RunProject tab<CR>", desc = "RunProject", noremap = true, silent = false },
  { "<leader>rc", mode = "n", "<Cmd>RunClose<CR>", desc = "RunClose", noremap = true, silent = false },
  { "<leader>ref", mode = "n", "<Cmd>CRFiletype<CR>", desc = "CRFiletype", noremap = true, silent = false },
  { "<leader>rep", mode = "n", "<Cmd>CRProjects<CR>", desc = "CRProjects", noremap = true, silent = false },

  { "<leader>s", group = "Surround" },
  { "<leader>ss", mode = "n", "<Plug>(nvim-surround-normal-cur)", desc = "nvim-surround-normal-cur", noremap = true, silent = false },
  { "<leader>sd", mode = "n", "<Plug>(nvim-surround-delete)", desc = "nvim-surround-delete", noremap = true, silent = false },
  { "<leader>sl", mode = "n", "<Plug>(nvim-surround-normal-cur-line)", desc = "nvim-surround-normal-cur-line", noremap = true, silent = false },
  { "<leader>sr", mode = "n", "<Plug>(nvim-surround-change)", desc = "nvim-surround-change", noremap = true, silent = false },

  -- <Plug>(nvim-surround-insert)
  -- <Plug>(nvim-surround-insert-line)
  -- <Plug>(nvim-surround-normal)
  -- <Plug>(nvim-surround-normal-cur)
  -- <Plug>(nvim-surround-normal-line)
  -- <Plug>(nvim-surround-normal-cur-line)
  -- <Plug>(nvim-surround-visual)
  -- <Plug>(nvim-surround-visual-line)
  -- <Plug>(nvim-surround-change)
  -- <Plug>(nvim-surround-change-line)

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
