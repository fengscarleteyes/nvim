return {
  "saghen/blink.cmp",
  dependencies = { { "luozhiya/fittencode.nvim" }, "rafamadriz/friendly-snippets" },
  version = "*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      ghost_text = { enabled = false },
      menu = {
        min_width = 15,
        max_height = 10,
        scrollbar = false,
        border = "single",
        draw = {
          treesitter = { "lsp" },
          columns = {
            { "label", "label_description", gap = 2 },
            { "kind_icon", "kind", gap = 2 },
          },
        },
      },
      documentation = {
        window = { scrollbar = false, border = "single" },
        auto_show = true,
        auto_show_delay_ms = 50,
      },
      list = { selection = "auto_insert" },
      accept = {
        auto_brackets = { enabled = true },
      },
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
      default = { "lazydev", "lsp", "path", "snippets", "buffer", "markdown" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        markdown = {
          name = "RenderMarkdown",
          module = "render-markdown.integ.blink",
          fallbacks = { "lsp" },
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
-- TODO: config keymaps
