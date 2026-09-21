-- ============================================================
-- 备选主题：tokyonight（当前不生效）
-- ------------------------------------------------------------
-- 本文件以 .disabled 结尾，lua/theme.lua 的 glob lua/theme/*.lua 不会命中它，
-- 因此不会被加载。想切换主题时：
--   1. 把本文件名改回 tokyonight.lua；
--   2. 把 lua/theme/colorscheme.lua 移出该目录（或同样改成 .disabled），
--      否则两个主题会按文件名字典序互相覆盖。
-- ============================================================

vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
})

require("tokyonight").setup({ transparent = vim.g.transparent_enabled })
vim.cmd("colorscheme tokyonight-night")
