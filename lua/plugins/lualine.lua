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
        -- {
        --     function ()
        --         return require("lspsaga.symbol.winbar").get_bar()
        --     end
        -- }

        -- {
        --   function() return require("noice").api.status.command.get() end,
        --   cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
        --   color = Util.fg("Statement"),
        -- },
        -- {
        --   function() return require("noice").api.status.mode.get() end,
        --   cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        --   color = Util.fg("Constant"),
        -- },
        -- {
        --   function() return "  " .. require("dap").status() end,
        --   cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
        --   color = Util.fg("Debug"),
        -- },
        {
          "searchcount",
          maxcount = 999,
          timeout = 500,
        },
        {
          "diff",
          --   symbols = {
          --     added = icons.git.added,
          --     modified = icons.git.modified,
          --     removed = icons.git.removed,
          --   },
        },
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_z = {
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
