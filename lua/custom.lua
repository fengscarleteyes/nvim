-- ============================================================
-- 自定义功能入口（加载 lua/custom/）
-- ------------------------------------------------------------
-- 本文件不写任何功能实现，只负责按顺序调用 lua/custom/ 下各模块的 setup()。
-- 这里用 require + setup，而不是 lua/plugins.lua 那样的 :runtime!：
--   1. 这些模块是「返回 M + M.setup(opts) 生效」的模块写法，:runtime! 只做 source、
--      不会调用 setup()；
--   2. 模块会被别处 require 复用（如 lua/plugins/dashboard-nvim.lua 里的
--      require("custom.terminal")），用 require 能保证全局只有一个模块实例，
--      避免「source 一份 + require 一份」造成重复注册。
-- 模块与入口分离：lua/custom/ 下只放模块，入口是本文件（同级）。
--   notify.lua       浮动通知（接管 vim.notify：边框按等级着色、自动关闭；:NotifyTest 查看效果）
--   clean.lua        :RemoveStateDir / :RemoveShadaDir 维护命令
--   yank.lua         复制（yank）后短暂高亮
--   terminal.lua     终端：浮动窗口 / 右侧对半分割 / 底部 1/3 分割
--   autopair.lua     自动配对（setup 注册映射/命令）
--   diagnostics.lua  诊断统计窗口（底部浮动窗显示各级别数量）+ :DiagNext/:DiagPrev/:DiagCopyLine/:DiagCopyBuffer
--   tabline.lua      单条信息栏 tabline（buffer / tab / window 数量 + 当前文件名）
--   winbar.lua       窗口顶栏面包屑（LSP documentSymbol 的符号层级路径）
--   autonotify.lua   模式切换时用 vim.notify 提醒 filetype + 模式（可按文件类型禁用）
--
-- 模块约定（标准 Neovim 插件写法）：
--   1. 每个模块返回 M，require 本身不产生副作用，功能由 M.setup(opts) 生效；
--   2. M.setup 幂等：重复调用只会注册一次（模块内以 initialized 标记守护）；
--   3. 配置项集中在模块内的 DEFAULTS，用户传入的 opts 逐项覆盖；
--   4. 功能与其键位/命令/自动命令放在同一个文件里，入口只做调用。
--   新增功能：在 lua/custom/ 下新建模块，然后在下面补一行 setup() 调用即可。
-- ============================================================

-- 浮动通知：接管 vim.notify（放在最前，后续模块 setup 期间的通知也走浮动提示）
-- 命令：:NotifyTest [level] / :NotifyClose / :NotifyToggle；配置项见该文件头部注释
require("custom.notify").setup()

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

-- 诊断高亮 + 诊断提醒（默认按文件类型禁用诊断：mason / dashboard）
require("custom.diagnostics").setup()

-- tabline：一条占满整行的信息栏（buffer / tab / window 数量 + 当前文件名）
require("custom.tabline").setup()

-- winbar：窗口顶栏面包屑（LSP documentSymbol 的符号层级路径；不含文件名，tabline 已有）
-- 命令：:WinbarToggle（显示 / 隐藏）:WinbarRefresh（重新取符号）
require("custom.winbar").setup()
