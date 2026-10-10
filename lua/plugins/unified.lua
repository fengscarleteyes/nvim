vim.pack.add({
  "https://github.com/axkirillov/unified.nvim",
})

-- 按约定不绑键位：本插件不注册任何默认映射（只在自己弹出的 help 缓冲里绑
-- q / <Space> / <CR> / <Esc> 用于关闭），操作入口是命令 —— 注意 :Unified 是由
-- setup() 创建的（本插件没有 plugin/ 目录），所以下面这行 setup 不能省：
--   :Unified        当前 buffer 的统一 diff（带文件树）
--   :Unified -t     同上，但在新 tab 里打开，不动当前窗口布局
-- 配置默认值见其 lua/unified/config.lua：signs / highlights / line_symbols /
-- auto_refresh / jump_to_first_hunk / tab / file_tree{enabled,width,filename_first,focus}，
-- 需要改就往 setup({ ... }) 里传。
require("unified").setup({})
