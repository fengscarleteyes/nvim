-- https://github.com/Exafunction/codeium.vim
return {
  "Exafunction/codeium.vim",
  -- enabled = false,
  event = "BufEnter",
  -- Codeium Auth to set up the plugin and start using Codeium

  config = function()
    -- Change '<C-g>' here to any keycode you like.
    -- vim.g.codeium_disable_bindings = 1
    -- vim.key.set({ "text" })

    vim.keymap.set("i", "<C-g>", function()
      return vim.fn["codeium#Accept"]()
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<c-;>", function()
      return vim.fn["codeium#CycleCompletions"](1)
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<c-,>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<c-x>", function()
      return vim.fn["codeium#Clear"]()
    end, { expr = true, silent = true })
  end,
}
