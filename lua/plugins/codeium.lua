return {
  "Exafunction/codeium.nvim",
  cmd = "Codeium",
  build = ":Codeium Auth",
  opts = {
    enable_cmp_source = false,
    virtual_text = {
      enabled = true,
      manual = false,
      filetypes = {},
      default_filetype_enabled = true,
      idle_delay = 75,
      virtual_text_priority = 65535,
      map_keys = false,
      -- map_keys = true,
      accept_fallback = nil,
      key_bindings = {},
    },
  },
}
