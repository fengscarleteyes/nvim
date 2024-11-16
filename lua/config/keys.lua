-- Example
-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover) -- hover
-- vim.keymap.set('n', '<M-Tab>', function () vim.cmd('NeoTermToggle') end)
-- vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermEnterNormal') end)

-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover)

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

-- stylua: ignore
local wk = require("which-key")
wk.add({
  { "<leader>", group = "keys" }, -- group
  { "<leader><F5>", mode = "n", function() require("oil").toggle_float()             end, desc = "Oil toggle"           },

  { '<leader><F1>', mode = "n", function() require('telescope.builtin').find_files() end, desc = "telescope find files" },
  { '<leader><F2>', mode = "n", function() require('telescope.builtin').buffers()    end, desc = "telescope buffers"    },
  { '<leader><F3>', mode = "n", function() require('telescope.builtin').live_grep()  end, desc = "telescope live grep"  },
  { '<leader><F4>', mode = "n", function() require('telescope.builtin').help_tags()  end, desc = "telescope help tags"  },

  { "<leader><F10>", mode = { "t", "n" }, function() require('FTerm').toggle()       end, desc = "FTerm toggle"         },

  -- { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  -- { "<leader>fb", function() print("hello") end, desc = "Foobar" },
  -- { "<leader>fn", desc = "New File" },
  -- { "<leader>f1", hidden = true }, -- hide this keymap
  -- { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
  -- { "<leader>b", group = "buffers", expand = function()
  --     return require("which-key.extras").expand.buf()
  --   end
  -- },
  -- {
  --   -- Nested mappings are allowed and can be added in any order
  --   -- Most attributes can be inherited or overridden on any level
  --   -- There's no limit to the depth of nesting
  --   mode = { "n", "v" }, -- NORMAL and VISUAL mode
  --   { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
  --   { "<leader>w", "<cmd>w<cr>", desc = "Write" },
  -- }
})

-- local keys = {
--   ['<leader>'] = {
--     name = '快捷键预览 - leader',

--     [] = {   }

--     ['b'] = {
--       name = '缓冲 | 内容',
--       -- ['1'] = { '<cmd> buffers! <CR>', '缓冲区 列出 含 列表外', mode = 'n' },
--       -- ['2'] = { '<cmd> bdelete <CR>', '缓冲区 删除', mode = 'n' },
--       -- ['b'] = { '<cmd> bwipe <CR>', '缓冲区 擦除 含列表外', mode = 'n' },
--       -- ['n'] = { '<cmd> bNext <CR>', '缓冲区 下一个', mode = 'n' },
--     },
--     ['f'] = {
--       name = '文件 | 搜索',
--       ['1'] = { '<cmd> SFMToggle <CR>', '文件树', mode = 'n' },
--       ['2'] = { '<cmd> Alpha <CR>', '欢迎屏幕', mode = 'n' },
--       ['3'] = { builtin.find_files, '模糊搜索 文件', mode = 'n' },
--       ['4'] = { builtin.buffers, '模糊搜索 缓冲区', mode = 'n' },
--       ['5'] = { builtin.live_grep, '模糊搜索 文件内容', mode = 'n' },
--       ['6'] = { builtin.help_tags, '模糊搜索 帮助', mode = 'n' },
--       ['7'] = { '<cmd> TodoTelescope <CR>', '模糊搜索 待办搜索', mode = 'n'},
--       ['8'] = { '<cmd> TodoTrouble <CR>', '模糊搜索 待办列表', mode = 'n'},
--     },
--   }
-- }

-- return keys
