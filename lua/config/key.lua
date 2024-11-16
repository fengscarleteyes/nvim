-- Example
-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover) -- hover
-- vim.keymap.set('n', '<M-Tab>', function () vim.cmd('NeoTermToggle') end)
-- vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermEnterNormal') end)

-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover)

-- stylua: ignore

  -- stylua: ignore
  -- keys = {
  --   { '<F1>', mode = "n", function() require('telescope.builtin').find_files() end, desc = "telescope find files" },
  --   { '<F2>', mode = "n", function() require('telescope.builtin').buffers()    end, desc = "telescope buffers"    },
  --   { '<F3>', mode = "n", function() require('telescope.builtin').live_grep()  end, desc = "telescope live grep"  },
  --   { '<F4>', mode = "n", function() require('telescope.builtin').help_tags()  end, desc = "telescope help tags"  },
  -- },

  -- stylua: ignore
  -- keys = {
  --   { "<F5>", mode = "n", function() require("oil").toggle_float() end, desc = "Oil toggle" },
  -- },

-- vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-;>", function()
--   return vim.fn["codeium#CycleCompletions"](1)
-- end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-,>", function()
--   return vim.fn["codeium#CycleCompletions"](-1)
-- end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-x>", function()
--   return vim.fn["codeium#Clear"]()
-- end, { expr = true, silent = true })

-- keys = {
--   { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
--   { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
--   { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
--   { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
--   { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
-- },

-- keys = {
--   { "<F10>", mode = "n", "<CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
--   { "<F10>", mode = "t", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
-- },

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