---@module "snacks"
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
}
-- ---@module "snacks"
--
-- return {
--   "folke/snacks.nvim",
--   enabled = false,
--   priority = 1000,
--   lazy = false,
--   opts = {
--     bigfile = { enabled = true },
--     bufdelete = { enabled = true },
--     dashboard = {
--       sections = {
--         -- { section = "header" },
--         { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
--         { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
--         { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
--         { section = "startup" },
--       },
--     },
--     input = { enabled = true },
--     indent = { enabled = true },
--     notifier = { timeout = 3000 },
--     quickfile = { exclude = { "latex" } },
--     words = { notify_jump = true },
--     scroll = { enabled = false },
--     scope = { enabled = false },
--     statuscolumn = {
--       enable = false,
--       left = { "mark", "sign" }, -- priority of signs on the left (high to low)
--       right = { "fold", "git" }, -- priority of signs on the right (high to low)
--       folds = {
--         open = true,
--         git_hl = true,
--       },
--     },
--     terminal = { enabled = true },
--   },
--   init = function()
--     vim.api.nvim_create_autocmd("User", {
--       pattern = "VeryLazy",
--       callback = function()
--         -- Snacks.indent.enable()
--
--         local wk = require("which-key")
--         wk.add({ { "<leader>u", group = "Snacks | toggles" } })
--
--         -- stylua: ignore start
--         Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
--         Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
--         Snacks.toggle.diagnostics():map("<leader>ud")
--         Snacks.toggle.line_number():map("<leader>ul")
--         Snacks.toggle.treesitter():map("<leader>uT")
--         Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
--         Snacks.toggle.inlay_hints():map("<leader>uh")
--         Snacks.toggle.indent():map("<leader>ui")
--         Snacks.toggle.dim():map("<leader>uD")
--         Snacks.toggle.zen():map("<leader>uz")
--
--         _G.dd = function(...) Snacks.debug.inspect(...) end
--         _G.bt = function()    Snacks.debug.backtrace()  end
--         vim.print = _G.dd -- Override print to use snacks for `:=` command
--         -- stylua: ignore end
--       end,
--     })
--   end,
-- }
