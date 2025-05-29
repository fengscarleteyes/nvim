return {
  "yarospace/lua-console.nvim",
  lazy = true,
  keys = {
    { "`", desc = "Lua-console - toggle" },
    -- { "<Leader>`", desc = "Lua-console - attach to buffer" },
  },
  -- opts = { preserve_context = false, clear_before_eval = true, notify_result = true },
  opts = {},
  config = function(_, opts)
    require("lua-console").setup(opts)
  end,
}
