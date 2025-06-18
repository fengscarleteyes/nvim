-- https://github.com/chrisgrieser/nvim-origami

return {
  "chrisgrieser/nvim-origami",
  enabled = false,
  event = "VeryLazy",
  opts = {
    useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
    autoFold = {
      enabled = false,
      kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
    },
    foldtextWithLineCount = {
      enabled = not package.loaded["ufo"],
      template = "   %s lines", -- `%s` gets the number of folded lines
      hlgroupForCount = "Comment",
    },

    pauseFoldsOnSearch = true,
    foldKeymaps = {
      setup = false,
      hOnlyOpensOnFirstColumn = false,
    },
    keepFoldsAcrossSessions = package.loaded["ufo"],
  },
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
  end,
  config = function(_, opts)
    require("origami").setup(opts)
  end,
}
