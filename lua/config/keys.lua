local wk = require("which-key")
wk.add({
  {
    "<leader><Space>",
    mode = "n",
    function()
      require("noice").cmd("dismiss")
    end,
    desc = "noice dismiss",
  },

  { "<leader>", group = "leader keys" }, -- group
  { "<leader>f", group = "File | Find" }, -- group
  {
    "<leader>fo",
    mode = "n",
    function()
      require("oil").toggle_float()
    end,
    desc = "Oil toggle",
  },

  {
    "<leader>ff",
    mode = "n",
    function()
      require("telescope.builtin").find_files()
    end,
    desc = "telescope find files",
  },
  {
    "<leader>fb",
    mode = "n",
    function()
      require("telescope.builtin").buffers()
    end,
    desc = "telescope buffers",
  },
  {
    "<leader>fg",
    mode = "n",
    function()
      require("telescope.builtin").live_grep()
    end,
    desc = "telescope live grep",
  },
  {
    "<leader>fh",
    mode = "n",
    function()
      require("telescope.builtin").help_tags()
    end,
    desc = "telescope help tags",
  },

  {
    "<A-t>",
    mode = { "t", "n" },
    function()
      require("FTerm").toggle()
    end,
    desc = "FTerm toggle",
  },

  {
    "s",
    mode = { "n", "x", "o" },
    function()
      require("flash").jump()
    end,
    desc = "Flash",
  },
  {
    "S",
    mode = { "n", "x", "o" },
    function()
      require("flash").treesitter()
    end,
    desc = "Flash Treesitter",
  },
  {
    "r",
    mode = "o",
    function()
      require("flash").remote()
    end,
    desc = "Remote Flash",
  },
  {
    "R",
    mode = { "o", "x" },
    function()
      require("flash").treesitter_search()
    end,
    desc = "Treesitter Search",
  },
  {
    "<c-s>",
    mode = { "c" }, -- in "/" search mode toggle flash
    function()
      require("flash").toggle()
    end,
    desc = "Toggle Flash Search",
  },

  {
    "<C-g>",
    mode = "i",
    function()
      return vim.fn["codeium#Accept"]()
    end,
    desc = "Accept Codeium",
    expr = true,
    silent = true,
  },
  {
    "<C-;>",
    mode = "i",
    function()
      return vim.fn["codeium#CycleCompletions"](1)
    end,
    desc = "codeium CycleCompletions",
    expr = true,
    silent = true,
  },
  {
    "<C-,>",
    mode = "i",
    function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end,
    desc = "codeium CycleCompletions",
    expr = true,
    silent = true,
  },
  {
    "<C-x>",
    mode = "i",
    function()
      return vim.fn["codeium#Clear"]()
    end,
    desc = "codeium clear",
    expr = true,
    silent = true,
  },

  { "<leader>r", group = "RunCode" },
  { "<leader>rr", mode = "n", "<Cmd>RunCode<CR>", desc = "RunCode", noremap = true, silent = false },
  { "<leader>rf", mode = "n", "<Cmd>RunFile tab<CR>", desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp", mode = "n", "<Cmd>RunProject tab<CR>", desc = "RunProject", noremap = true, silent = false },
  { "<leader>rc", mode = "n", "<Cmd>RunClose<CR>", desc = "RunClose", noremap = true, silent = false },
  { "<leader>rcf", mode = "n", "<Cmd>CRFiletype<CR>", desc = "CRFiletype", noremap = true, silent = false },
  { "<leader>rcp", mode = "n", "<Cmd>CRProjects<CR>", desc = "CRProjects", noremap = true, silent = false },

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
