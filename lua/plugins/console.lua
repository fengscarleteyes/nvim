-- https://github.com/LintaoAmons/scratch.nvim
-- https://github.com/athar-qadri/scratchpad.nvim
return {
  "yarospace/lua-console.nvim",
  lazy = true,
  enabled = false,
  -- keys = { "`", "<Leader>`" },
  opts = {
    mappings = {
      toggle = false,
      attach = false,
      quit = false,
      eval = false,
      eval_buffer = false,
      open = false,
      messages = false,
      save = false,
      load = false,
      resize_up = false,
      resize_down = false,
      help = false,
    },
  },
}
