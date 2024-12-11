return {
  "luozhiya/fittencode.nvim",
  -- enabled = false,
  -- enabled = function()
  --   if vim.fn.has("win32") == 1 then
  --     return true
  --   elseif vim.fn.has("unix") == 1 then
  --     return false
  --   end
  -- end,
  -- enabled = true,
  opts = {
    action = {
      document_code = { show_in_editor_context_menu = false },
      edit_code = { show_in_editor_context_menu = false },
      explain_code = { show_in_editor_context_menu = false },
      find_bugs = { show_in_editor_context_menu = false },
      generate_unit_test = { show_in_editor_context_menu = false },
      start_chat = { show_in_editor_context_menu = false },
      identify_programming_language = {
        identify_buffer = true,
      },
    },
    inline_completion = { enable = false },
    source_completion = {
      enable = true,
      engine = "cmp", -- "cmp" | "blink"
      trigger_chars = {},
    },
    completion_mode = "source",
    -- completion_mode = "inline",
  },
}
