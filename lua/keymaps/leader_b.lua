--stylua: ignore start
return {
  { "<leader>b", group = "Buffer" },
  { "<leader>bl", mode = { "n" }, "<Cmd>BufferList<CR>",                desc = "bufferlist",             noremap = true, silent = true },
  { "<leader>bs", mode = { "n" }, ":lua Snacks.scratch()<CR>",          desc = "Snacks scaratch",        noremap = true, silent = true },
  { "<leader>bS", mode = { "n" }, ":lua Snacks.scratch.select()<CR>",   desc = "Snacks scaratch select", noremap = true, silent = true },
  { "<leader>bb", mode = { "n" }, ":lua Snacks.bufdelete()<CR>",        desc = "BufferClose",            noremap = true, silent = true },
  }
-- stylua: ignore end
