vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
})
require("tokyonight").setup({ transparent = vim.g.transparent_enabled })
vim.cmd("colorscheme tokyonight-night")

-- vim.pack.add({
--   "https://github.com/mitander/flume.nvim",
-- })
-- vim.opt.termguicolors = true
-- require("flume").setup({ schema = "dusk" })

-- vim.pack.add({
--   {
--     src = 'https://github.com/ThorstenRhau/token',
--     version = vim.version.range('*'),
--   },
-- })
-- local token = require('token')
-- ---@type token.Config
-- local config = {
--   transparent = false,
--   plugins = { gitsigns = true, snacks = true },
-- }
-- token.setup(config)
-- vim.cmd.colorscheme('token') -- or 'token-ultra', 'token-meridian', 'token-flint', 'token-temper'
