-- https://github.com/nanozuki/tabby.nvim

return {
  "nanozuki/tabby.nvim",
  -- enabled = false,
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"
    local theme = {
      fill = "TabLineFill",
      -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
      head = "TabLine",
      current_tab = "TabLineSel",
      tab = "TabLine",
      win = "TabLine",
      tail = "TabLine",
    }
    -- local theme = {
    --   -- this is carbonfox theme
    --   fill = "TabLineFill",
    --   head = { fg = "#75beff", bg = "#1c1e26", style = "italic" },
    --   current_tab = { fg = "#1c1e26", bg = "#75beff", style = "italic" },
    --   tab = { fg = "#c5cdd9", bg = "#1c1e26", style = "italic" },
    --   win = { fg = "#1c1e26", bg = "#75beff", style = "italic" },
    --   tail = { fg = "#75beff", bg = "#1c1e26", style = "italic" },
    -- }
    require("tabby.tabline").set(function(line)
      return {
        {
          -- { " 󰤌 ", hl = theme.head },
          { " 󰤌 ", hl = theme.fill },
          -- line.sep("", theme.head, theme.fill),
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          -- remove count of wins in tab with [n+] included in tab.name()
          local name = tab.name()
          local index = string.find(name, "%[%d")
          local tab_name = index and string.sub(name, 1, index - 1) or name
          return {
            -- line.sep(" ", hl, theme.fill),
            line.sep(" ", hl, theme.fill),
            tab_name,
            -- line.sep(" ", hl, theme.fill),
            line.sep(" ", hl, theme.fill),
            hl = hl,
            margin = " ",
          }
        end),
        line.spacer(),
        {
          -- line.sep("", theme.head, theme.fill),
          -- { "  ", hl = theme.head },
          { "  ", hl = theme.fill },
        },
        hl = theme.fill,
      }
    end)
  end,
}
