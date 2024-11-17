-- https://github.com/Exafunction/codeium.vim
return {
  "Exafunction/codeium.vim",
  -- enabled = false,
  event = "BufEnter",
  -- Codeium Auth to set up the plugin and start using Codeium
  config = function()
    -- Change '<C-g>' here to any keycode you like.
    vim.g.codeium_disable_bindings = 1
  end,
}
