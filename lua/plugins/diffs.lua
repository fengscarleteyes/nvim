vim.pack.add({
  "https://github.com/barrettruth/diffs.nvim",
})

-- 按约定不绑键位：本插件对外只注册 <Plug>(diffs-*) 映射（见其 plugin/diffs.lua 末尾），
-- 不占任何用户按键；操作入口是命令：
--   :Diff              当前文件的 diff
--   :Diff review       跨文件审查（列出工作区改动，逐个文件过）
--   :Diff files a b    任意两个文件对比
--   :Diff <rev>        与指定 revision 对比（命令补全由插件提供）
-- 它在自己的 diff / review 缓冲里会设 buffer 局部键（q 关闭、文件间跳转等），那是插件
-- UI 自身的操作键，不影响普通编辑缓冲。
--
-- 注意它的配置方式与别的插件不同：**没有** require("diffs").setup() ——
-- 配置是从 vim.g.diffs 读的，且在插件加载期读取（plugin/diffs.lua:7）。
-- 要改配置就写 vim.g.diffs = { ... }，默认值见其 lua/diffs/config.lua。
-- 另外 require("diffs") 返回的是公开 API 表（attach / open_review / refresh /
-- review_* 等），供脚本调用，不是 setup 入口。
