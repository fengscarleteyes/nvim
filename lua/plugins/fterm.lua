return {
  "numToStr/FTerm.nvim",
  opts = { cmd = "powershell" }, -- windows
  -- opts = { cmd = "bash" }, -- linux
  -- stylua: ignore
  keys = {
    { "<F10>", mode = "n", "<CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
    { "<F10>", mode = "t", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
  },
}
