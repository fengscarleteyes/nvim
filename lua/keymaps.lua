-- ============================================================
-- 键位映射入口（加载 lua/keymaps/）
-- ------------------------------------------------------------
-- 本文件不写任何映射，只负责把 lua/keymaps/*.lua 依次执行一遍（写法同 lua/plugins.lua）：
--   :runtime! 会按 'runtimepath' 顺序查找 lua/keymaps/*.lua 并 source 之，
--   因此新增一组键位只需在 lua/keymaps/ 下新建 .lua 文件，本文件不用改。
--
-- 约定与注意：
--   1. 本文件必须放在 lua/keymaps/ 之外：glob lua/keymaps/*.lua 会命中目录内的
--      任何 .lua，放在里面会自我递归 source；
--   2. <leader> 由 lua/options/leader.lua 设置，root init.lua 里 options 先于 keymaps，
--      所以各文件里的 <leader> 都能正确展开；
--   3. vim.keymap.set 的默认值即 noremap=true、nowait=false、expr=false，
--      所以每条映射只写 { silent = true, desc = "..." } 即可，
--      与旧声明表里那 5 项 opts（noremap/silent/nowait/expr/desc）完全等价；
--   4. 执行顺序：同目录内按文件名字典序；同一条 lhs 在多处重复设置时，靠后的生效；
--   5. 禁用一组键位：把文件移出本目录（如 lua/keymaps/bak/）或改名 xxx.lua.disabled。
-- ============================================================

vim.cmd("runtime! lua/keymaps/*.lua")
