return {
  "hedyhli/outline.nvim",
  -- enabled = false,
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  opts = {
    outline_window = { position = "left", auto_jump = true },
    preview_window = {
      -- auto_preview = true,
      -- open_hover_on_preview = true,
      auto_preview = false,
      open_hover_on_preview = false,
    },
  },
}
