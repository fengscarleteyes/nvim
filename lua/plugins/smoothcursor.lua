-- https://github.com/gen740/SmoothCursor.nvim

return {
  "gen740/SmoothCursor.nvim",
  enabled = false,
  opts = {
    type = "default",
    disabled_filetypes = { "lazy" },
    fancy = {
      enable = true, -- enable fancy mode
      head = { cursor = "", texthl = "SmoothCursor", linehl = nil }, -- false to disable fancy head
      body = {
        { cursor = "", texthl = "SmoothCursorRed" }, -- 
        { cursor = "", texthl = "SmoothCursorOrange" },
        { cursor = "", texthl = "SmoothCursorYellow" },
        { cursor = "", texthl = "SmoothCursorGreen" },
        { cursor = "", texthl = "SmoothCursorAqua" },
        { cursor = "", texthl = "SmoothCursorBlue" },
        { cursor = "", texthl = "SmoothCursorPurple" },
      },
      tail = { cursor = nil, texthl = "SmoothCursor" }, -- false to disable fancy tail
    },
  },
}
