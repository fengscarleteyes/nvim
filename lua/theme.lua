-- ============================================================
-- 主题入口（加载 lua/theme/）
-- ------------------------------------------------------------
-- 本文件不写任何配色，只负责把 lua/theme/*.lua 依次执行一遍（写法同 lua/plugins.lua）：
--   :runtime! 会按 'runtimepath' 顺序查找 lua/theme/*.lua 并 source 之。
--   生效的主题放 lua/theme/ 下（当前是 colorscheme.lua），
--   备选主题放 lua/theme/tokyonight.lua.disabled，改名去掉 .disabled 即可启用。
--   注意：同时存在多个主题文件时，字典序靠后的文件最终决定配色。
-- ============================================================

vim.cmd("runtime! lua/theme/*.lua")
