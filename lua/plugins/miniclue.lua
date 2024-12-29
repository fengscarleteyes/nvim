-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md
-- TODO: learn how to use ...
return {
  "echasnovski/mini.clue",
  enabled = false,
  version = false,
  opts = {},
  config = function(_, opts)
    require("mini.clue").setup(opts)
  end,
}
