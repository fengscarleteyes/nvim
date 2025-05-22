-- https://github.com/Saghen/blink.nvim
-- https://github.com/saghen/blink.cmp

return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "moyiz/blink-emoji.nvim",
    "folke/lazydev.nvim",
  },
  version = "*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    cmdline = {
      enabled = true,
      completion = {
        trigger = {
          show_on_blocked_trigger_characters = {},
          show_on_x_blocked_trigger_characters = {},
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
        menu = { auto_show = true },
        ghost_text = { enabled = true },
      },
      keymap = { preset = "super-tab" },
      sources = function()
        local type = vim.fn.getcmdtype()
        -- Search forward and backward
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        -- Commands
        if type == ":" or type == "@" then
          return { "cmdline" }
        end
        return {}
      end,
    },
    completion = {
      ghost_text = { enabled = false },
      menu = {
        auto_show = true,
        -- min_width = 15,
        max_height = 10,
        scrollbar = false,
        border = "rounded",
        draw = {
          components = {
            item_idx = {
              text = function(ctx)
                return tostring(ctx.idx)
              end,
              highlight = "BlinkCmpItemIdx",
            },
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
          treesitter = { "lsp" },
          columns = {
            { "item_idx" },
            { "kind_icon", "kind", gap = 2 },
            { "label", "label_description", gap = 2 },
          },
        },
      },
      documentation = {
        window = { scrollbar = false, border = "single" },
        auto_show = true,
        auto_show_delay_ms = 0,
      },
      list = {
        selection = { preselect = true, auto_insert = true },
      },
      accept = {
        auto_brackets = { enabled = false, default_brackets = { "(", ")" } },
      },
    },
    signature = { enabled = true, window = { border = "single" } },
    keymap = {
      preset = "none", -- disable default preset
      -- stylua: ignore start
      ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
      ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
      ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
      ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
      ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
      ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
      ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
      ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
      ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
      -- stylua: ignore end
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
    appearance = {
      use_nvim_cmp_as_default = true,
      -- use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },

    sources = {
      min_keyword_length = function()
        return vim.bo.filetype == "markdown" and 2 or 0
      end,
      default = { "omni", "lsp", "lazydev", "path", "snippets", "buffer", "markdown", "emoji" },
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
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
