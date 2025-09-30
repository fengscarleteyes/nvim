-- https://github.com/tris203/precognition.nvim

return {
  "tris203/precognition.nvim",
  -- enabled = false,
  event = "VeryLazy",
  opts = {
    startVisible = true,
    -- showBlankVirtLine = true,
    highlightColor = { link = nil, fg = "#00FF00" },
    hints = {
      Caret = { text = "^", prio = 0 },
      Dollar = { text = "$", prio = 0 },
      MatchingPair = { text = "%", prio = 0 },
      Zero = { text = "0", prio = 0 },
      w = { text = "w", prio = 0 },
      b = { text = "b", prio = 0 },
      e = { text = "e", prio = 0 },
      W = { text = "W", prio = 0 },
      B = { text = "B", prio = 0 },
      E = { text = "E", prio = 0 },
    },
    gutterHints = {
      G = { text = "G", prio = 5 },
      gg = { text = "gg", prio = 5 },
      PrevParagraph = { text = "{", prio = 5 },
      NextParagraph = { text = "}", prio = 5 },
    },
    disabled_fts = {
      "startify",
      "dashboard",
    },
  },
}
