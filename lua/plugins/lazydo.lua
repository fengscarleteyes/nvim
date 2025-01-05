return {
  "Dan7h3x/LazyDo",
  branch = "main",
  keys = { -- recommended keymap for easy toggle LazyDo in normal and insert modes (arbitrary)
    {
      "<F2>",
      "<ESC><CMD>LazyDoToggle<CR>",
      mode = { "n", "i" },
    },
  },
  event = "VeryLazy",
  opts = {
    -- your config here
  },
}
-- TODO: config keymaps
-- config lualine
-- {
--     "nvim-lualine/lualine.nvim",
--     event = "VeryLazy",
--     opts = function(_, opts)
--       table.insert(opts.sections.lualine_x, {
--         function()
--           return require("lazydo").get_lualine_stats()
--         end,
--         cond = function()
--           return require("lazydo")._initialized
--         end,
--       })
--     end,
--   }
