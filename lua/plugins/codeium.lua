vim.g.codeium_disable_bindings = 1
vim.g.codeium_enabled = true

return {
  "Exafunction/codeium.nvim",
  enabled = function()
    if vim.fn.has("win32") == 1 then
      return false
    elseif vim.fn.has("unix") == 1 then
      return true
    end
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({})
  end,
}
