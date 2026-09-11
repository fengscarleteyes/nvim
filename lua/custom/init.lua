-- ============================================================
-- 自定义功能入口（lua/custom/）
-- ------------------------------------------------------------
-- 本文件只负责按顺序加载同目录下的功能模块，不写任何具体实现。
--   clean.lua        :RemoveStateDir / :RemoveShadaDir 维护命令
--   yank.lua         复制（yank）后短暂高亮
--   floatterm.lua    浮动终端（setup 绑定键位）
--   autopair.lua     自动配对（require 即按默认配置生效）
--   diagnostics.lua  诊断高亮 + 诊断提醒
--
-- 模块约定：
--   1. 功能与其键位/命令/自动命令放在同一个文件里，入口只做调用；
--   2. 无对外 API 的用「require 即生效」的写法（不返回值）；
--      有对外 API 的返回 M，并由入口调用其 setup()。
--   新增功能：在 lua/custom/ 下新建模块，然后在下面补一行即可。
-- ============================================================

-- 维护命令：清理 state / shada 目录
require("custom.clean")

-- 复制后高亮被复制的内容
require("custom.yank")

-- 浮动终端：绑定 <C-\>（普通/终端模式切换）与终端模式 <Esc>（关闭）
-- 也可 require("custom.floatterm").setup({ map_keys = false }) 只加载不绑键
require("custom.floatterm").setup()

-- 自动配对：require 即启用；如需自定义配置，改成
-- require("custom.autopair").setup({ ... })，可用项见该文件头部注释
require("custom.autopair")

-- 诊断高亮 + 诊断提醒
require("custom.diagnostics")
