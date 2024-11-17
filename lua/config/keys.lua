-- Example
-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover) -- hover

-- keys = {
-- keys = {
--   { "<A-1>", vim.lsp.buf.hover, mode = "n", desc = "hover" },
--   { "<A-2>", vim.lsp.buf.rename, mode = "n", desc = "definition" },
--   { "<A-3>", vim.lsp.buf.definition, mode = "n", desc = "rename" },
--   { "<A-4>", vim.lsp.buf.code_action, mode = "n", desc = "code_action" },
--   -- todo
--   -- vim.lsp.buf.format()
--   -- vim.lsp.buf.completion()
--   -- vim.lsp.buf.formatting()
--   -- vim.lsp.buf.references()
--   -- vim.lsp.buf.declaration()
--   -- vim.lsp.buf.server_ready()
--   -- vim.lsp.buf.typehierarchy()
--   -- vim.lsp.buf.implementation()
--   -- vim.lsp.buf.incoming_calls()
--   -- vim.lsp.buf.outgoing_calls()
--   -- vim.lsp.buf.signature_help()
--   -- vim.lsp.buf.document_symbol()
--   -- vim.lsp.buf.execute_command()
--   -- vim.lsp.buf.formatting_sync()
--   -- vim.lsp.buf.type_definition()
--   -- vim.lsp.buf.clear_references()
--   -- vim.lsp.buf.range_formatting()
--   -- vim.lsp.buf.workspace_symbol()
--   -- vim.lsp.buf.range_code_action()
--   -- vim.lsp.buf.document_highlight()
--   -- vim.lsp.buf.add_workspace_folder()
--   -- vim.lsp.buf.list_workspace_folders()
--   -- vim.lsp.buf.remove_workspace_folder()
-- },

local wk = require("which-key")
wk.add({
  { "<leader>", group = "keys" }, -- group
  {
    "<leader><F5>",
    mode = "n",
    function()
      require("oil").toggle_float()
    end,
    desc = "Oil toggle",
  },

  {
    "<F6>",
    mode = "n",
    function()
      require("noice").cmd("dismiss")
    end,
    desc = "noice dismiss",
  },

  {
    "<leader><F1>",
    mode = "n",
    function()
      require("telescope.builtin").find_files()
    end,
    desc = "telescope find files",
  },
  {
    "<leader><F2>",
    mode = "n",
    function()
      require("telescope.builtin").buffers()
    end,
    desc = "telescope buffers",
  },
  {
    "<leader><F3>",
    mode = "n",
    function()
      require("telescope.builtin").live_grep()
    end,
    desc = "telescope live grep",
  },
  {
    "<leader><F4>",
    mode = "n",
    function()
      require("telescope.builtin").help_tags()
    end,
    desc = "telescope help tags",
  },

  {
    "<leader><F10>",
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
    mode = { "c" },
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

  { "<leader>r", mode = "n", "<Cmd>RunCode<CR>", desc = "RunCode", noremap = true, silent = false },
  { "<leader>rf", mode = "n", "<Cmd>RunFile<CR>", desc = "RunFile", noremap = true, silent = false },
  { "<leader>rft", mode = "n", "<Cmd>RunFile tab<CR>", desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp", mode = "n", "<Cmd>RunProject<CR>", desc = "RunProject", noremap = true, silent = false },
  { "<leader>rc", mode = "n", "<Cmd>RunClose<CR>", desc = "RunClose", noremap = true, silent = false },
  { "<leader>crf", mode = "n", "<Cmd>CRFiletype<CR>", desc = "CRFiletype", noremap = true, silent = false },
  { "<leader>crp", mode = "n", "<Cmd>CRProjects<CR>", desc = "CRProjects", noremap = true, silent = false },

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

  -- todo lspsaga
})
