-- ============================================================
-- 选项设置入口（加载 lua/options/）
-- ------------------------------------------------------------
-- 本文件不写任何选项，只负责把 lua/options/*.lua 依次执行一遍（写法同 lua/plugins.lua）：
--   :runtime! 会按 'runtimepath' 顺序查找 lua/options/*.lua 并 source 之，
--   因此新增/调整设置只需在 lua/options/ 下新建或修改文件，本文件不用改。
--
-- 约定与注意：
--   1. 本文件必须放在 lua/options/ 之外：glob lua/options/*.lua 会命中目录内的
--      任何 .lua，放在里面会自我递归 source；
--   2. 执行顺序：同目录内按文件名字典序，即
--      completion -> files -> folds -> general -> indent -> leader -> search -> ui；
--      同一选项在多处重复设置时，字典序靠后的文件生效（completeopt 就属于这种情况，
--      已按原顺序合并进 lua/options/completion.lua）；
--   3. 禁用某项：把文件移出本目录（如 lua/options/bak/）或改名 xxx.lua.disabled；
--   4. 某个文件报错不会中断其余文件，但整体仍以报错结束（同 lua/plugins.lua）。
-- ============================================================

vim.cmd("runtime! lua/options/*.lua")
