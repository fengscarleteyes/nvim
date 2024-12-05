return {
  "Exafunction/codeium.nvim",
  cmd = "Codeium",
  build = ":Codeium Auth",
  enabled = function()
    if vim.fn.has("win32") == 1 then
      return false
    elseif vim.fn.has("unix") == 1 then
      return true
    end
  end,

  opts = {
    -- detect_proxy = "https://192.168.10.118:7890",
    enable_cmp_source = false,
    virtual_text = {
      manual = false,
      filetypes = {},
      default_filetype_enabled = true,
      idle_delay = 75,
      virtual_text_priority = 65535,
      -- map_keys = false,
      map_keys = true,
      accept_fallback = nil,
      key_bindings = {
        -- Accept the current completion.
        accept = "<Tab>",
        -- Accept the next word.
        accept_word = false,
        -- Accept the next line.
        accept_line = false,
        -- Clear the virtual text.
        clear = false,
        -- Cycle to the next completion.
        next = "<M-]>",
        -- Cycle to the previous completion.
        prev = "<M-[>",
      },
    },
  },
}
