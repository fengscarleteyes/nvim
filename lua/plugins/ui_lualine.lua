return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      -- icons_enabled = false,
      -- component_separators = { left = '', right = ''},
      -- section_separators = { left = '', right = ''},
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
      disabled_filetypes = { statusline = { "dashboard", "alpha" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        {
          "diagnostics",
          symbols = {
            error = " ",
            warn = " ",
            info = " ",
            hint = " ",
          },
        },
        -- {
        --   function()
        --     return '|||||'
        --   end,
        -- },
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        {
          "filename",
          path = 1,
          symbols = { modified = "  ", readonly = "", unnamed = "" },
          -- padding = { left = 10, right = 10 },
        },
      },
      lualine_x = {
        {
          "searchcount",
          maxcount = 999,
          timeout = 500,
        },
        {
          "diff",
          symbols = {
            added = "+",
            modified = "*",
            removed = "-",
          },
        },
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_z = {
        { require("codeium.virtual_text").status_string, color = { bg = "#009900" } },
        {
          function()
            local s = require("codeium.virtual_text").status()
            return s.state
          end,
          color = { bg = "#009900" },
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { bg = "#00FF00" },
        },
      },
    },
    extensions = { "lazy" },
  },
}
