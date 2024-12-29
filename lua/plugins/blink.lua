return {
  "saghen/blink.cmp",
  dependencies = "rafamadriz/friendly-snippets",
  version = "*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      ghost_text = { enabled = true },
      menu = {
        border = "single",
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", gap = 1 },
          },
        },
      },
      documentation = { window = { border = "single" }, auto_show = true, auto_show_delay_ms = 50 },
      -- list = { selection = "auto_insert" },
    },
    signature = { enabled = true },
    keymap = {
      -- https://cmp.saghen.dev/configuration/keymap.html#presets
      preset = "super-tab",
      -- <C-space> | show_documentation / hide_documentation
      -- <C-e>     | hide
      -- <Tab>     | accept
      -- <S-Tab>   | snippet_backward
      -- <Up>      | select_prev"
      -- <Down>    | select_next"
      -- <C-p>     | select_prev"
      -- <C-n>     | select_next"
      -- <C-b>     | scroll_documentation_up"
      -- <C-f>     | scroll_documentation_down"
      -- cmdline = {}, -- default Disable cmdline completions
      cmdline = {
        preset = "super-tab",
      },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "fittencode" },
      providers = {
        fittencode = {
          name = "fittencode",
          module = "fittencode.sources.blink",
        },
        snippets = {
          opts = {
            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
          },
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
