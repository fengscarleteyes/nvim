return {
  "numToStr/FTerm.nvim",
  opts = { cmd = "powershell" },
  -- opts = { cmd = "bash" },
  -- stylua: ignore
  keys = {
    { "<F10>", mode = "n", "<CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
    { "<F10>", mode = "t", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
  },
}
