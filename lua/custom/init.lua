-- ============================================================
-- 自定义功能入口（lua/custom/）
-- ------------------------------------------------------------
-- 本文件只负责按顺序加载同目录下的功能模块，不写任何具体实现。
--   clean.lua        :RemoveStateDir / :RemoveShadaDir 维护命令
--   yank.lua         复制（yank）后短暂高亮
--   terminal.lua     终端：浮动窗口 / 右侧对半分割 / 底部 1/3 分割
--   autopair.lua     自动配对（setup 注册映射/命令）
--   diagnostics.lua  诊断高亮 + 诊断提醒
--   tabline.lua      单条信息栏 tabline（buffer / tab / window 数量 + 当前文件名）
--
-- 模块约定（标准 Neovim 插件写法）：
--   1. 每个模块返回 M，require 本身不产生副作用，功能由 M.setup(opts) 生效；
--   2. M.setup 幂等：重复调用只会注册一次（模块内以 initialized 标记守护）；
--   3. 配置项集中在模块内的 DEFAULTS，用户传入的 opts 逐项覆盖；
--   4. 功能与其键位/命令/自动命令放在同一个文件里，入口只做调用。
--   新增功能：在 lua/custom/ 下新建模块，然后在下面补一行 setup() 调用即可。
-- ============================================================

-- 维护命令：清理 state / shada 目录
require("custom.clean").setup()

-- 复制后高亮被复制的内容
require("custom.yank").setup()

-- 终端：默认键位见该文件头部（<C-\> 浮动、<leader>tr 右侧对半、<leader>tb 底部 1/3）
-- 也可 require("custom.terminal").setup({ map_keys = false }) 只注册命令、不绑键位
require("custom.terminal").setup()

-- 自动配对：默认配置；如需自定义，改成
-- require("custom.autopair").setup({ ... })，可用项见该文件头部注释
require("custom.autopair").setup()

-- 诊断高亮 + 诊断提醒
require("custom.diagnostics").setup()

-- tabline：一条占满整行的信息栏（buffer / tab / window 数量 + 当前文件名）
require("custom.tabline").setup()
