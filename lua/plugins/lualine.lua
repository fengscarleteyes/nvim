return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      -- icons_enabled = false,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      -- component_separators = { left = "", right = "" },
      -- section_separators = { left = "", right = "" },
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
        {
          color = { bg = "#0055FF", fg = "#FFFFFF" },
          function()
            local emoji = { " ", "󰏤 ", " ", "⚠️ ", " ", " " }
            return "󰚩  " .. emoji[require("fittencode").get_current_status()]
          end,
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
