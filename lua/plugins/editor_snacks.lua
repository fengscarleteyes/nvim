---@module 'snacks'

return {
  "folke/snacks.nvim",
  -- enabled = false,
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = true },
    -- dashboard = { enabled = false },
    notifier = { enabled = true, timeout = 3000 },
    quickfile = { enabled = true },
    words = { enabled = true },
    statuscolumn = {
      enabled = true,
      folds = {
        open = true,
        git_hl = true,
      },
    },
    terminal = {
      enabled = true,
      -- win = { style = "terminal" },
    },
    toggle = {},
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  },
  -- init = function()
  --   vim.api.nvim_create_autocmd("User", {
  --     pattern = "VeryLazy",
  --     callback = function()
  --       -- Setup some globals for debugging (lazy-loaded)
  --       _G.dd = function(...)
  --         Snacks.debug.inspect(...)
  --       end
  --       _G.bt = function()
  --         Snacks.debug.backtrace()
  --       end
  --       vim.print = _G.dd -- Override print to use snacks for `:=` command
  --
  --       -- Create some toggle mappings
  --       Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us") -- pinxiejiancha
  --       Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw") -- zidonghuanhang
  --       Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
  --       Snacks.toggle.line_number():map("<leader>ul")
  --       Snacks.toggle.diagnostics():map("<leader>ud")
  --       Snacks.toggle
  --         .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
  --         :map("<leader>uc")
  --       Snacks.toggle.treesitter():map("<leader>uT")
  --       Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
  --       Snacks.toggle.inlay_hints():map("<leader>uh")
  --     end,
  --   })
  -- end,
}
