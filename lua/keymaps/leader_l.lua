--stylua: ignore start
return {
  { "<leader>l", group = "Lsp" },
  { "<leader>lo", mode = { "n" },  "<Cmd>Outline<CR>",                 desc = "toggle outline",          noremap = true, silent = false },
  { "<leader>lr", mode = { "n" },  "<Cmd>Lspsaga rename<CR>",          desc = "Rename",                  noremap = true, silent = false }, -- quit = '<C-k>'
  { "<leader>ld", mode = { "n" },  "<Cmd>Lspsaga peek_definition<CR>", desc = "definition",              noremap = true, silent = false }, -- quit = '<C-k>'
  { "<leader>lin", mode = { "n" }, "<Cmd>Lspsaga incoming_calls<CR>",  desc = "incoming calls",          noremap = true, silent = false },
  { "<leader>loc", mode = { "n" }, "<Cmd>Lspsaga outgoing_calls<CR>",  desc = "incoming calls",          noremap = true, silent = false },
  -- { "<leader>lD", mode = { "n" }, "<CMD>Glance definitions<CR>",      desc = "Glance definitions",      noremap = true, silent = false },
  -- { "<leader>lR", mode = { "n" }, "<CMD>Glance references<CR>",       desc = "Glance references",       noremap = true, silent = false },
  -- { "<leader>lY", mode = { "n" }, "<CMD>Glance type_definitions<CR>", desc = "Glance type_definitions", noremap = true, silent = false },
  -- { "<leader>lM", mode = { "n" }, "<CMD>Glance implementations<CR>",  desc = "Glance implementations",  noremap = true, silent = false },
  }
-- stylua: ignore end

-- TODO: add custom keymap