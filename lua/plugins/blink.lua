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
      list = {
        selection = { preselect = true, auto_insert = true },
      },
      accept = {
        auto_brackets = { enabled = true, default_brackets = { "(", ")" } },
      },
    },
    signature = { enabled = true, window = { border = "single" } },
    keymap = {
      -- https://cmp.saghen.dev/configuration/keymap.html#presets
      preset = "none", -- disable default preset
      ["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback",
      },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      -- cmdline = {}, -- default Disable cmdline completions
      cmdline = {
        -- preset = "super-tab",
        preset = "none",
        ["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
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
