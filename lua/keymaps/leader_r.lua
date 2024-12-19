--stylua: ignore start
return {
  { "<leader>r", group = "RunCode" },
  { "<leader>rr",  mode = { "n" }, "<Cmd>RunCode<CR>",        desc = "RunCode",     noremap = true, silent = false },
  { "<leader>rf",  mode = { "n" }, "<Cmd>RunFile tab<CR>",    desc = "RunFile tab", noremap = true, silent = false },
  { "<leader>rp",  mode = { "n" }, "<Cmd>RunProject tab<CR>", desc = "RunProject",  noremap = true, silent = false },
  { "<leader>rc",  mode = { "n" }, "<Cmd>RunClose<CR>",       desc = "RunClose",    noremap = true, silent = false },
  { "<leader>ref", mode = { "n" }, "<Cmd>CRFiletype<CR>",     desc = "CRFiletype",  noremap = true, silent = false },
  { "<leader>rep", mode = { "n" }, "<Cmd>CRProjects<CR>",     desc = "CRProjects",  noremap = true, silent = false },
}
-- stylua: ignore end
