return {
  "numToStr/FTerm.nvim",
  opts = function()
    if vim.fn.has("win32") == 1 then
      return { cmd = "powershell" }
    elseif vim.fn.has("unix") == 1 then
      return { cmd = "bash" }
    end
  end,
  -- opts = { cmd = "powershell" }, -- windows
  -- opts = { cmd = "bash" }, -- linux
  -- stylua: ignore
  keys = {
    { "<F10>", mode = "n", "<CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
    { "<F10>", mode = "t", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", desc = "FTerm toggle" },
  },
}
