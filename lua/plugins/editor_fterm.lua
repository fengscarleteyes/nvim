return {
  "numToStr/FTerm.nvim",
  opts = function()
    if vim.fn.has("win32") == 1 then
      return { cmd = "powershell" }
    elseif vim.fn.has("unix") == 1 then
      return { cmd = "bash" }
    end
  end,
}
