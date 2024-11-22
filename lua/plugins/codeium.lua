vim.g.codeium_disable_bindings = 1

return {
  "Exafunction/codeium.vim",
  enabled = function()
    if vim.fn.has("win32") == 1 then
      return false
    elseif vim.fn.has("unix") == 1 then
      return true
    end
  end,
  event = "BufEnter",
  -- Codeium Auth to set up the plugin and start using Codeium
  -- https://github.com/Exafunction/codeium.vim
  -- vim.g.codeium_disable_bindings = 1
}
