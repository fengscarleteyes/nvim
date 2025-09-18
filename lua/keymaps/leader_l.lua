--stylua: ignore start
return {
  { "<leader>l", group = "Lsp" },
  { "<leader>lr", mode = { "n" },  "<Cmd>Lspsaga rename<CR>",          desc = "Rename",                  noremap = true, silent = false }, -- quit = '<C-k>'
  { "<leader>ld", mode = { "n" },  "<Cmd>Lspsaga peek_definition<CR>", desc = "definition",              noremap = true, silent = false }, -- quit = '<C-k>'
  { "<leader>lin", mode = { "n" }, "<Cmd>Lspsaga incoming_calls<CR>",  desc = "incoming calls",          noremap = true, silent = false },
  { "<leader>loc", mode = { "n" }, "<Cmd>Lspsaga outgoing_calls<CR>",  desc = "incoming calls",          noremap = true, silent = false },
  }
-- stylua: ignore end