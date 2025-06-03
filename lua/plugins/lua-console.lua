-- https://github.com/YaroSpace/lua-console.nvim
-- TODO: config lua-console.nvim & keymap

return {
  "yarospace/lua-console.nvim",
  lazy = true,
  keys = {
    { "`", desc = "Lua-console - toggle" },
    -- { "<Leader>`", desc = "Lua-console - attach to buffer" },
  },
  opts = {
    buffer = {
      result_prefix = "=> ",
      save_path = vim.fn.stdpath("state") .. "/lua-console.lua",
      autosave = true, -- autosave on console hide / close
      load_on_start = true, -- load saved session on start
      preserve_context = false, -- preserve results between evaluations
      strip_local = true, -- remove local identifier from source code
      show_one_line_results = true, -- prints one line results, even if already shown as virtual text
      notify_result = false, -- notify result
      clear_before_eval = true, -- clear output below result prefix before evaluation of the whole buffer
      process_timeout = 2 * 1e5, -- number of instructions to process before timeout
    },
    window = {
      border = "double", -- single|double|rounded
      height = 0.6, -- percentage of main window
    },
    mappings = {
      toggle = "`", -- toggle console
      attach = false, -- "<Leader>`", -- attach console to a buffer
      quit = "q", -- close console
      eval = "<CR>", -- evaluate code
      eval_buffer = "<S-CR>", -- evaluate whole buffer
      kill_ps = false, -- "<Leader>K", -- kill evaluation process
      open = false, -- "gf", -- open link
      messages = "M", -- load Neovim messages
      save = "S", -- save session
      load = "L", -- load session
      resize_up = "<C-Up>", -- resize up
      resize_down = "<C-Down>", -- resize down
      help = "?", -- help
    },
  },
}
