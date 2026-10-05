-- lua/custom/dashboard.lua
-- 启动仪表盘（Neovim 原生 API 实现；标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
-- 两个功能：
--   1. 历史文件快速进入：列出最近文件 —— 当前已打开的文件（含刚编辑还没写盘的）排在前面，
--      后面接 shada 里的 v:oldfiles（只保留仍可读的真实文件），去重后数字键 1..9（第 10 条为 0）
--      直接打开，不必先跳去文件树或查找器；历史记录可以一键清空（clear_history()，默认快捷键 d）；
--   2. 自定义快捷功能：shortcuts 配置项，每项 { icon, key, desc, action }，
--      action 是函数就直接调用，是字符串就当 :命令 执行，按键即触发。
-- 外观（powerline 风格；没有标题、没有分割线、没有分区标题）：
--   * 每条都是铺满固定宽度的「色条」：底色贯通整行，行尾用 Nerd Font 箭头收口；
--       [ 序号 / 按键徽标 ]▏ 图标 文件名 ……… 所在目录▏
--   * 序号（历史文件）与按键（快捷功能）用不同颜色的徽标区分，徽标后紧跟一个过渡
--     箭头接到色条底色 —— 一眼就能看出「按哪个键」，不必再写「历史文件 / 快捷功能」；
--   * 色条与箭头一定会画（不受配色配置影响）；配色自带 dark / light 两套预设（默认 dark，
--     colors = "light" 换一套），也能只改 colors 里的 6 个角色（bar / index / key / icon /
--     text / dim）；行尾箭头与徽标过渡箭头的颜色由 bar / 徽标底色自动推出来，不用手写；
--     跟主题就给角色写 { link = "主题组名" }；切换主题后自动重新应用。
--
-- 布局：
--   * 用一个 scratch buffer 顶替当前窗口的内容（filetype = <cfg.filetype>，默认 "dashboard"），
--     所以 custom.winbar 不会画面包屑、custom.diagnostics 不会弹面板；
--   * 内容水平居中、垂直居中，窗口尺寸变化时自动重排；
--   * 打开文件（历史文件 / 快捷功能）时，dashboard 缓冲区按 bufhidden = wipe 自动清掉；
--     q / <Esc> 关闭 dashboard 时，换回打开前的那个缓冲区；
--   * 显示期间会临时改掉该窗口的局部选项（行号 / 光标线 / 不可见字符等，见 apply_win_opts），
--     只改本窗口（scope = "local"，不动全局默认值），关闭 / 离开 dashboard 后原样还原
--     （见 restore_stale_win_opts），不会影响其它窗口与之后新建的窗口。
--
-- API：
--   require("custom.dashboard").setup([opts])        合并配置 + 注册命令 / 自动命令（幂等；键位来自 shortcuts）
--   require("custom.dashboard").open()               打开（或聚焦）dashboard（每次打开都重读历史文件并重绘）
--   require("custom.dashboard").close()              关闭（换回打开前的缓冲区）
--   require("custom.dashboard").clear_history([opts]) 清空最近文件历史（v:oldfiles；默认立刻写回 shada）
--                                                     opts: include_open（默认 true，把清空前用过的已打开文件
--                                                           也一起隐去）、persist（默认 true 写回 shada）、
--                                                           notify（默认 true 弹提示）
--                                                     只清历史记录、不删文件；本次会话里打开过 / 之后打开的
--                                                     文件仍会照常进入历史（Neovim 的 oldfiles 行为）
--   require("custom.dashboard").quit()               退出 Neovim（有未保存的修改时只提示）
--   require("custom.dashboard").toggle()             打开 / 关闭切换
--   require("custom.dashboard").is_open()            当前是否已打开
--   require("custom.dashboard").apply_highlights()   重新应用自带配色（切换主题后会自动调用）
--   require("custom.dashboard").highlights()         取各角色使用的高亮组名（固定 CustomDashboard*）
--
-- 用户命令：
--   :Dashboard  :DashboardClose  :DashboardToggle
--   （没有刷新命令 / 键位：每次打开都会重读历史文件并重绘）
--
-- 面板内键位：没有单独的键位配置，全部来自 shortcuts（列表里每一项就是一个键）：
--   q                  退出 Neovim（有其他未保存的修改时只提示、不强退）
--   <Esc>              关闭 dashboard（换回打开前的缓冲区）
--   d                  清空最近文件历史（v:oldfiles + 清空前用过的已打开文件；文件本身不会被删，
--                      之后再用到的文件会重新出现在列表里；本次会话打开过的文件下次启动仍会照常记录）
--   1..9 / 0           打开第 1..10 条历史文件（条数不足时对应键不生效）
--   其余               shortcuts 里各自的 key（默认 u / m / g / f / c / h，见 DEFAULTS.shortcuts）
--   键位冲突：shortcuts 按列出顺序先占位，历史文件的数字键再占剩下的（见「键位分配」）。
--   想在普通模式里按键打开 / 关闭 dashboard，就自己绑命令，例如
--     vim.keymap.set("n", "<leader>fo", "<Cmd>DashboardToggle<CR>", { desc = "Dashboard: 打开 / 关闭" })
--   提示：dashboard 是 nomodifiable 的，编辑类按键会报 E21，这是预期行为（用 <Esc> 关闭 / q 退出）。
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   autoload   boolean  true      无参数启动（nvim 后不带文件名、起始缓冲区为空）时自动显示
--   width      number   60        内容宽度 = 窗口宽度的百分比（默认 60 = 60%；范围 10..100，
--                                 窗口太窄时按「窗口宽度 - 4」收窄，最少 10 列；
--                                 每条色条都铺满这个宽度）
--   mru = {                       最近文件（分区 1）
--     enable       boolean true   是否显示该分区
--     limit        number  9      最多显示几条（> 9 的部分只展示、不给按键）
--     cwd_only     boolean false  true = 只显示当前工作目录下的文件
--     open_buffers boolean true   true = 把当前已打开的文件也算进最近文件（排在 v:oldfiles 前面）；
--                                 v:oldfiles 只在启动 / 退出写 shada 时更新，本次会话新打开或刚编辑的
--                                 文件不在里面，靠它才能立刻看到；设 false 就只列 v:oldfiles
--   }                             清空历史：clear_history()（见上面的 API / 面板内键位）
--   shortcuts = {                 自定义快捷功能（列表，每项 { icon, key, desc, action }；传了就整体替换默认列表）
--     { icon = "字形", key = "u", desc = "更新插件", action = function() vim.pack.update() end },
--     { icon = "", key = "q", desc = "退出 Neovim", action = function() require("custom.dashboard").quit() end },
--   }                             列出即显示；key 与别的项冲突时该项只展示、不给键（见「键位分配」）
--   icons = {                     各处的 Nerd Font 字形（icons = false 则图标字形都不显示）
--     sep    = nr2char(0xE0B0)   色条箭头字形：一定会画，这里只换形状（置 "" / icons = false 仍是默认箭头）
--     file   = 字形              文件字形（所有文件都用它；置 "" 则不显示）
--   }
--   colors     string|table "dark" 配色：自带 dark / light 两套预设（默认 dark），也可以只改几个角色
--                                 * "dark" / "light"                    直接选一套预设
--                                 * { preset = "light" }                选预设（不写 preset 就是 dark）
--                                 * { preset = "light", index = {...} } 选预设 + 只覆盖想改的角色（deep merge）
--                                 6 个角色（行尾箭头 / 徽标过渡箭头的颜色都由它们推出来）：
--                                   bar   = { fg, bg }  色条底色：整行贯通
--                                   index = { fg, bg }  历史文件序号徽标（dark 默认亮蓝底深字）
--                                   key   = { fg, bg }  快捷功能按键徽标（dark 默认亮黄底深字）
--                                   icon  = "#rrggbb"   行内字形
--                                   text  = "#rrggbb"   文件名 / 说明文字
--                                   dim   = "#rrggbb"   文件所在目录（次要信息）
--                                 覆盖规则：角色写 { ... } 表就与预设里同名角色 deep merge（只写想改的字段，
--                                 其余沿用预设）；写 "#rrggbb" / 其它类型就整体替换。写法：
--                                   { fg, bg, bold } 完整写；"#rrggbb" 简写（只给字色）；
--                                   { link = "主题高亮组" } 直接复用主题组的颜色（跟随主题就用它）
--   filetype   string   "dashboard"  dashboard 缓冲区的 filetype
--
-- 键位分配：shortcuts 里先列出的先占位，然后才是历史文件的数字键 ——
-- 冲突的一方直接忽略（只展示、不给按键），不会出现一个键绑两个功能。
-- shortcuts 传了就整体替换默认列表：自己写列表时如果没写「退出 / 关闭」，面板里就没有这些键
-- （还可以用 :DashboardClose 等命令）。
-- 本模块只在 dashboard 缓冲区里绑键位，不占用任何全局键位；普通模式要按键打开 / 关闭，
-- 就自己绑一个命令（示例见上面「面板内键位」）。
--
-- 示例：
--   require("custom.dashboard").setup()                          -- 全默认
--   require("custom.dashboard").setup({ mru = { limit = 12 } })  -- 多列几条历史文件
--   require("custom.dashboard").setup({ width = 70 })            -- 内容宽度 = 窗口宽度的 70%（默认 60）
--   require("custom.dashboard").setup({                          -- 自定义快捷功能（整体替换默认列表）
--     shortcuts = {
--       { icon = "", key = "e", desc = "文件树", action = "Neotree filesystem toggle" },
--       { icon = "", key = "d", desc = "清除历史", action = function() require("custom.dashboard").clear_history() end },
--       { icon = "", key = "q", desc = "退出 Neovim", action = function() require("custom.dashboard").quit() end },
--     },
--   })
--   require("custom.dashboard").setup({ colors = "light" })      -- 换浅色预设（默认 dark）
--   require("custom.dashboard").setup({ colors = { index = { bg = "#bb9af7" } } }) -- 只改序号徽标底色
--   require("custom.dashboard").setup({ colors = { preset = "light", dim = { link = "Comment" } } }) -- 预设 + 微调
-- ============================================================

local M = {}

--- 色条箭头字形（powerline 右箭头 U+E0B0）：一定会画，icons.sep 只用来换形状
local DEFAULT_SEP = vim.fn.nr2char(0xe0b0)

--- 默认配置
local DEFAULTS = {
  autoload = true, -- 无参数启动时自动显示
  width = 60, -- 内容宽度 = 窗口宽度的百分比（10..100）
  mru = { -- 最近文件（当前已打开的文件 + v:oldfiles）
    enable = true,
    limit = 9, -- 最多显示几条（> 9 的部分只展示、不给按键）
    cwd_only = false,
    open_buffers = true, -- 把当前已打开的文件也算进来（v:oldfiles 不含本次会话新打开 / 编辑的文件）
  },
  shortcuts = { -- 自定义快捷功能（图标 / 键位 / 说明 / 动作）
    {
      icon = "󰚰",
      key = "u",
      desc = "PackUpdate",
      action = function()
        vim.pack.update()
      end,
    },
    { icon = "󰏖", key = "m", desc = "Mason", action = "Mason" },
    {
      icon = "",
      key = "g",
      desc = "Lazygit",
      action = function()
        require("custom.terminal").run("lazygit")
      end,
    },
    { icon = "󰈞", key = "f", desc = "FindFile", action = "FzfLua files" },
    { icon = "󰏘", key = "c", desc = "FindTheme", action = "FzfLua colorschemes" },
    { icon = "󰋚", key = "h", desc = "History", action = "FzfLua oldfiles" },
    {
      icon = "󰆴",
      key = "d",
      desc = "ClearHistory",
      action = function()
        M.clear_history()
      end,
    },
    {
      icon = "󰿅",
      key = "q",
      desc = "Quit",
      action = function()
        M.quit()
      end,
    },
  },
  icons = { -- 各处的 Nerd Font 字形（icons = false 则图标字形都不显示）
    sep = DEFAULT_SEP, -- 色条箭头：一定会画，这里只换形状
    file = "󰧮", -- 文件字形（所有文件都用它；置 "" 则不显示）
  },
  colors = "dark", -- 配色预设：dark / light（默认 dark）；也可以写 { preset = ..., 角色 = ... } 微调
  filetype = "dashboard", -- dashboard 缓冲区的 filetype（custom.winbar / custom.diagnostics 已按它排除）
}

-- 可以直接配置的配色角色（apply_highlights 按这 6 项设置高亮组；其余高亮组由它们推出来）
local COLOR_ROLES = { "bar", "index", "key", "icon", "text", "dim" }

-- 自带的两套配色预设：同样 6 个角色，dark 是默认（高对比深色，亮底 / 深底主题都能看清）
local COLOR_PRESETS = {
  dark = {
    bar = { fg = "#c0caf5", bg = "#292e42" }, -- 色条底色：行尾箭头 / 徽标过渡箭头的颜色由它推出来
    index = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }, -- 历史文件序号徽标：亮蓝底深字
    key = { fg = "#1a1b26", bg = "#e0af68", bold = true }, -- 快捷功能按键徽标：亮黄底深字
    icon = "#ff9e64", -- 行内字形：亮橙（简写字符串 = 只给字色）
    text = "#c0caf5", -- 文件名 / 说明文字
    dim = "#7f86ad", -- 文件所在目录（次要信息）
  },
  light = {
    bar = { fg = "#3760bf", bg = "#e1e2e7" }, -- 浅色色条：浅灰底 + 深蓝字
    index = { fg = "#ffffff", bg = "#2e7de9", bold = true }, -- 历史文件序号徽标：蓝底白字
    key = { fg = "#ffffff", bg = "#b15c00", bold = true }, -- 快捷功能按键徽标：橙底白字
    icon = "#b15c00", -- 行内字形：橙
    text = "#3760bf", -- 文件名 / 说明文字：深蓝
    dim = "#6172a3", -- 文件所在目录（次要信息）
  },
}

--- 把 colors 配置解析成「6 个角色」的表：先选预设，再用配置里写的角色覆盖
---   "dark" / "light"                    直接选预设
---   { preset = "light", index = {...} } 选预设 + 只覆盖想改的角色
---   角色覆盖：表 + 表 -> deep merge（只写想改的字段，其余沿用预设）；写 "#rrggbb" / 其它 -> 整体替换
---   其它写法（nil / false / 不认识的预设名）都按默认预设 dark
--- @param value any 配置里的 colors
--- @return table 一定是可以直接用的 6 角色表
local function resolve_colors(value)
  local overrides = type(value) == "table" and value or nil
  local name = type(value) == "string" and value or (overrides and overrides.preset)
  local out = vim.deepcopy(COLOR_PRESETS[type(name) == "string" and name or ""] or COLOR_PRESETS.dark)
  for _, role in ipairs(COLOR_ROLES) do
    local role_value = overrides and overrides[role]
    if role_value ~= nil then
      local base = out[role]
      if type(base) == "table" and type(role_value) == "table" then
        out[role] = vim.tbl_deep_extend("force", vim.deepcopy(base), role_value)
      else
        out[role] = vim.deepcopy(role_value)
      end
    end
  end
  return out
end

-- 各角色使用的高亮组名（固定 CustomDashboard*，不用再配置前缀）
local HL = {
  bar = "CustomDashboardBar", -- 色条底色（整行贯通）
  index = "CustomDashboardIndex", -- 历史文件序号徽标
  key = "CustomDashboardKey", -- 快捷功能按键徽标
  icon = "CustomDashboardIcon", -- 行内字形
  text = "CustomDashboardText", -- 文件名 / 说明文字
  dim = "CustomDashboardDim", -- 文件所在目录
  tail = "CustomDashboardTail", -- 行尾收口箭头（字色 = 色条底色）
  sep_index = "CustomDashboardSepIndex", -- 序号徽标 -> 色条 的过渡箭头
  sep_key = "CustomDashboardSepKey", -- 按键徽标 -> 色条 的过渡箭头
}

-- nvim_set_hl 认识的属性：配置里写这些才算数（其它字段忽略，写错也不会报错）
local HL_ATTRS = { "fg", "bg", "bold", "italic", "underline", "undercurl", "strikethrough", "reverse", "nocombine" }

--- 把配置里的一条颜色变成可以直接交给 nvim_set_hl 的属性表（nil = 这一项不设置）
---   "#rrggbb"               只给字色
---   { fg, bg, bold, ... }   完整写，照抄
---   { link = "主题高亮组" }  到主题里取实际属性（跟随主题；切换主题后会重新取一次）
--- 除 bar 自己以外的角色都画在色条里：没写底色就补色条底色，色条才不会在行中间断色
--- @param value any 配置里写的值
--- @param role string 角色名
--- @param bar_color string 色条底色
--- @return table|nil
local function hl_attrs(value, role, bar_color)
  local spec = type(value) == "string" and { fg = value } or value
  if type(spec) ~= "table" then
    return nil
  end

  if type(spec.link) == "string" and spec.link ~= "" then
    local ok, attrs = pcall(vim.api.nvim_get_hl, 0, { name = spec.link, link = true })
    spec = ok and type(attrs) == "table" and attrs or nil
    if not spec then
      return nil -- 主题里没有这个组：这一项保持默认
    end
  end

  local out = {}
  for _, key in ipairs(HL_ATTRS) do
    if spec[key] ~= nil and spec[key] ~= "" then
      out[key] = spec[key]
    end
  end
  if next(out) == nil then
    return nil
  end
  if role ~= "bar" and out.bg == nil then
    out.bg = bar_color -- 色条内的角色：底色缺省 = 色条底色
  end
  return out
end

local cfg = vim.deepcopy(DEFAULTS)
cfg.colors = resolve_colors(cfg.colors) -- 预设名 / 覆盖表 -> 6 角色表（setup() 里会再解析一次）

local initialized = false -- setup() 是否已完成注册
local commands_created = false -- 用户命令是否已注册

local dash_buf = nil -- dashboard 缓冲区
local dash_win = nil -- dashboard 所在窗口
local prev_buf = nil -- 打开 dashboard 前该窗口里的缓冲区（关闭时换回去）
local saved_win_opts = {} -- [win] = { 选项名 = 占用前的窗口局部值 }：离开 dashboard 时还原（见 restore_win_opts）
local mru_cache = {} -- 最近一次渲染出的历史文件（数字键据此打开）
local key_plan = {} -- 最近一次渲染算出的键位分配（渲染与绑键位共用）
local bound_maps = {} -- [bufnr] = 该缓冲区上绑过的键位（重绑前先解绑，改配置后不残留）
local cleared_before = 0 -- 上次清空历史的时间戳（open_buffers 只保留之后又用过的文件；0 = 没清过）

local ns = vim.api.nvim_create_namespace("custom_dashboard")

-- ============================================================
-- 通用工具（宽度计算 / 截断）
-- ============================================================

--- 文本的显示宽度（strdisplaywidth 能正确处理中文、图标等非等宽字符）
--- @param text string|nil
--- @return integer
local function text_width(text)
  return vim.fn.strdisplaywidth(text or "")
end

--- 一行的显示宽度
--- @param chunks table[] { text, hl } 片段数组
--- @return integer
local function row_width(chunks)
  local total = 0
  for _, chunk in ipairs(chunks) do
    total = total + text_width(chunk.text)
  end
  return total
end

--- 内容宽度：窗口宽度 × cfg.width%（默认 60%），窗口太窄时不超过「窗口宽度 - 4」，最少 10 列
--- @param win_w integer 窗口宽度（列）
--- @return integer
local function content_width(win_w)
  local pct = math.max(10, math.min(100, tonumber(cfg.width) or DEFAULTS.width))
  return math.max(10, math.min(math.floor(win_w * pct / 100), win_w - 4))
end

--- 从头部截断（保留尾部，前面补 "…"）：文件所在目录用它，尾部信息更有用
--- @param text string
--- @param budget integer 可用显示宽度
--- @return string
local function truncate_head(text, budget)
  if budget <= 0 or text == "" then
    return ""
  end
  if text_width(text) <= budget then
    return text
  end
  for start = 1, vim.fn.strchars(text) do
    local cut = "…" .. vim.fn.strcharpart(text, start)
    if text_width(cut) <= budget then
      return cut
    end
  end
  return ""
end

--- 从尾部截断（保留头部，末尾补 "…"）：文件名、说明文字用它
--- @param text string
--- @param budget integer 可用显示宽度
--- @return string
local function truncate_tail(text, budget)
  if budget <= 0 or text == "" then
    return ""
  end
  if text_width(text) <= budget then
    return text
  end
  for len = vim.fn.strchars(text) - 1, 1, -1 do
    local cut = vim.fn.strcharpart(text, 0, len) .. "…"
    if text_width(cut) <= budget then
      return cut
    end
  end
  return "…"
end

--- 取一个字形（缺失 / 非字符串都按「不显示」处理）
--- @param name string
--- @return string
local function icon_of(name)
  local icons = cfg.icons
  if type(icons) ~= "table" then
    return ""
  end
  local value = icons[name]
  return type(value) == "string" and value or ""
end

-- ============================================================
-- 高亮（自带配色 + 色条箭头；只有 6 个角色可配，箭头颜色都是推出来的）
-- ============================================================

--- 各角色使用的高亮组名（固定是模块自带的 CustomDashboard*；色条与箭头一定会画）
--- @return table<string, string>
local function resolve_highlights()
  return vim.deepcopy(HL)
end

--- 色条底色：行尾箭头 / 徽标过渡箭头的颜色都由它推出来，所以一定有值（没写就用默认预设的值）
--- @return string
local function bar_bg()
  local attrs = hl_attrs(cfg.colors.bar, "bar", COLOR_PRESETS.dark.bar.bg)
  local bg = attrs and attrs.bg
  if type(bg) == "number" then
    return string.format("#%06x", bg) -- { link = ... } 取到的是数字，转回 #rrggbb
  end
  if type(bg) == "string" and bg ~= "" then
    return bg
  end
  return COLOR_PRESETS.dark.bar.bg
end

--- 色条箭头字形：一定会画（icons.sep 只用来换形状；留空 / icons = false 都用默认箭头）
--- @return string
local function arrow_glyph()
  local custom = icon_of("sep")
  return custom ~= "" and custom or DEFAULT_SEP
end

--- 应用自带配色：6 个可配置角色 + 3 个自动推出来的箭头组（色条与箭头一定会画）
--- cfg.colors 一定是 6 角色表（见 resolve_colors）
--- 切换配色方案会清空高亮组，所以由 ColorScheme 自动命令再次调用
local function apply_highlights()
  local bar_color = bar_bg()

  for _, role in ipairs(COLOR_ROLES) do
    local attrs = hl_attrs(cfg.colors[role], role, bar_color)
    if attrs then
      vim.api.nvim_set_hl(0, HL[role], attrs)
    end
  end

  -- 行尾收口箭头：字色 = 色条底色
  vim.api.nvim_set_hl(0, HL.tail, { fg = bar_color })

  -- 徽标 -> 色条 的过渡箭头：字色 = 徽标底色（没给底色的徽标就与色条同色），底色 = 色条底色
  for _, pair in ipairs({ { "index", "sep_index" }, { "key", "sep_key" } }) do
    local badge = hl_attrs(cfg.colors[pair[1]], pair[1], bar_color)
    vim.api.nvim_set_hl(0, HL[pair[2]], { fg = badge and badge.bg or bar_color, bg = bar_color })
  end
end

-- ============================================================
-- 内容来源（历史文件 / 快捷功能 / 键位分配）
-- ============================================================

--- 归一化 shortcuts：丢掉非法项，返回 { icon, key, desc, action } 列表
--- @return table[]
local function shortcut_items()
  local out = {}
  local shortcuts = type(cfg.shortcuts) == "table" and cfg.shortcuts or {}
  for _, item in ipairs(shortcuts) do
    if type(item) == "table" and type(item.key) == "string" and item.key ~= "" then
      local action = item.action
      local ok = type(action) == "function" or (type(action) == "string" and action ~= "")
      if ok then
        out[#out + 1] = {
          icon = type(item.icon) == "string" and item.icon or "",
          key = item.key,
          desc = type(item.desc) == "string" and item.desc or item.key,
          action = action,
        }
      end
    end
  end
  return out
end

--- 真实路径：用于判断两条 v:oldfiles 记录是不是同一个文件
--- Windows 的 shada 里同一个文件可能同时以 8.3 短名（C:\Users\FENGSC~1\...）
--- 和长名两种拼法出现，只看字符串会把同一个文件列两次，这里解析成真实路径去重
--- @param path string
--- @return string
local function real_path(path)
  local uv = vim.uv or vim.loop
  local real = uv and uv.fs_realpath and uv.fs_realpath(path)
  return real or path
end

--- 当前已打开的文件：buflisted、有名字、普通缓冲区（filetype 无特殊 buftype），按最近使用时间倒序
--- v:oldfiles 只在启动读 shada / 退出写 shada 时更新，本次会话里新打开或刚编辑的文件不在里面，
--- 所以必须把「已经打开的文件」也算进来，刚编辑过的文件才会立刻出现在面板上
--- 清空历史（M.clear_history）之后，比清空时间更早用过的已打开文件先隐去（之后再用到就会回来）
--- @return string[] 绝对路径
local function open_buffers()
  local found = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bufnr = info.bufnr
    local name = type(info.name) == "string" and info.name or ""
    local used = tonumber(info.lastused) or 0
    local normal = type(bufnr) == "number" and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ""
    if normal and name ~= "" and vim.fn.isdirectory(name) == 0 and used >= cleared_before then
      found[#found + 1] = { path = vim.fn.fnamemodify(name, ":p"), used = used }
    end
  end
  table.sort(found, function(a, b)
    return a.used > b.used
  end)
  local out = {}
  for _, item in ipairs(found) do
    out[#out + 1] = item.path
  end
  return out
end

--- 最近文件：当前已打开的文件（在前）+ v:oldfiles（在后），去重、保持最近使用顺序
--- @return string[] 绝对路径
local function recent_files()
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  local limit = math.max(0, tonumber(mru.limit) or 0)
  local cwd = mru.cwd_only and (vim.fn.getcwd() .. "/") or nil

  local sources = {}
  if mru.open_buffers ~= false then
    vim.list_extend(sources, open_buffers())
  end
  -- shada 里的历史文件：只保留仍然可读的真实文件
  for _, path in ipairs(vim.v.oldfiles or {}) do
    if type(path) == "string" and path ~= "" and vim.fn.filereadable(path) == 1 then
      sources[#sources + 1] = path
    end
  end

  local out, seen = {}, {}
  for _, path in ipairs(sources) do
    if #out >= limit then
      break
    end
    local full = vim.fn.fnamemodify(path, ":p")
    local key = real_path(full)
    if not seen[key] and (not cwd or vim.fn.stridx(full, cwd) == 0) then
      seen[key] = true
      out[#out + 1] = full
    end
  end
  return out
end

--- 第 index 条历史文件的按键：1..9，第 10 条用 0，再往后没有按键
--- @param index integer
--- @return string|nil
local function mru_key(index)
  if index >= 1 and index <= 9 then
    return tostring(index)
  end
  if index == 10 then
    return "0"
  end
  return nil
end

--- 执行一条快捷功能：函数直接调用，字符串当 :命令 执行
--- @param action function|string
local function run_action(action)
  if type(action) == "function" then
    action()
  elseif type(action) == "string" and action ~= "" then
    vim.cmd(action)
  end
end

--- 打开一个路径（dashboard 缓冲区 bufhidden = wipe，换缓冲区时自动清掉）
--- @param path string
local function open_path(path)
  if type(path) ~= "string" or path == "" then
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

--- 打开第 index 条历史文件
--- @param index integer
local function open_recent(index)
  open_path(mru_cache[index])
end

--- 键位分配：shortcuts 按列出顺序先占位（冲突的那一项只展示、不给键），
--- 历史文件的数字键再占剩下的（用户显式写的 key 优先于自动分配的数字键）
--- 注意：数字键的分配依赖 mru_cache，所以必须在 recent_files() 之后调用
--- @return table
local function allocate_keys()
  local used = {}

  --- 占用一个键位；已被占用 / 为空则返回 nil
  local function claim(lhs)
    if type(lhs) ~= "string" or lhs == "" or used[lhs] then
      return nil
    end
    used[lhs] = true
    return lhs
  end

  local items = {}
  for _, item in ipairs(shortcut_items()) do
    items[#items + 1] = { item = item, key = claim(item.key) }
  end

  local digits = {}
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  if mru.enable then
    for index = 1, #mru_cache do
      digits[index] = claim(mru_key(index))
    end
  end

  return { items = items, digits = digits }
end

-- ============================================================
-- 生成内容
-- ============================================================

--- 生成 dashboard 的每一行（{ text, hl } 片段数组），每行都不超过 width 列
--- @param width integer 内容宽度（列）
--- @return table[]
local function build_rows(width)
  local hl = HL -- 高亮组名固定，色条与箭头一定会画（见「高亮」）
  local rows = {}
  local cur = {} -- 当前行的片段：newrow() 每次赋新表（给空表是为了类型上不留 nil）

  --- 开始新的一行
  local function newrow()
    cur = {}
    rows[#rows + 1] = cur
  end

  --- 追加一个片段（空文本自动省略）
  --- @param text string
  --- @param group string|nil
  local function add(text, group)
    if type(text) == "string" and text ~= "" then
      cur[#cur + 1] = { text = text, hl = group }
    end
  end

  -- 段与段之间的过渡 / 行尾收口：powerline 右箭头（一定会画，见 arrow_glyph）
  local arrow = arrow_glyph()
  local arrow_w = arrow ~= "" and 1 or 0

  --- 一条铺满固定宽度的「色条」（powerline 风格，没有标题 / 分割线 / 分区标题）：
  ---   [ 序号 / 按键徽标 ]▏ 图标 正文 ………… 右侧信息▏
  --- 徽标自带底色，紧跟一个过渡箭头接到色条底色，行尾再用同色箭头收口；
  --- 徽标 + 图标 + 正文的宽度不够时先截正文、再截右侧信息，右侧信息贴住行尾。
  --- @param spec table { badge, badge_hl, arrow_hl, icon, text, text_hl, right, right_hl }
  local function bar_row(spec)
    local text = type(spec.text) == "string" and spec.text or ""
    local icon = type(spec.icon) == "string" and spec.icon or ""

    newrow()
    add(" ", hl.bar)
    if type(spec.badge) == "string" and spec.badge ~= "" then
      add(" " .. spec.badge .. " ", spec.badge_hl) -- 徽标：自带底色 + 深色字
      add(arrow, spec.arrow_hl) -- 徽标底色 -> 色条底色的过渡
    else
      add(string.rep(" ", 3 + arrow_w), hl.bar) -- 没有徽标：留出同样的宽度，保持左边对齐
    end
    add(" ", hl.bar)
    if icon ~= "" then
      add(icon .. " ", hl.icon)
    end

    -- 右侧信息（文件所在目录）：最多占一半宽度，其余留给正文
    local right = ""
    local avail = math.max(0, width - row_width(cur) - arrow_w)
    if type(spec.right) == "string" and spec.right ~= "" and avail > 12 then
      local budget = math.min(math.floor(width / 2), avail - 8)
      if budget >= 6 then
        right = "  " .. truncate_head(spec.right, budget - 2)
      end
    end

    add(truncate_tail(text, math.max(0, avail - text_width(right))), spec.text_hl)
    -- 用色条底色把这一行补满，最后收口
    add(string.rep(" ", math.max(0, width - row_width(cur) - text_width(right) - arrow_w)), hl.bar)
    add(right, spec.right_hl)
    add(arrow, hl.tail)
  end

  -- 一、历史文件：序号徽标 + 文件字形 + 文件名 + 所在目录（没有历史文件时这一分区不占行）
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  local mru_rows = 0
  if mru.enable == true then
    for index, path in ipairs(mru_cache) do
      bar_row({
        badge = key_plan.digits and key_plan.digits[index],
        badge_hl = hl.index,
        arrow_hl = hl.sep_index,
        icon = icon_of("file"),
        text = vim.fn.fnamemodify(path, ":t"),
        text_hl = hl.text,
        right = vim.fn.fnamemodify(path, ":~:h"),
        right_hl = hl.dim,
      })
      mru_rows = mru_rows + 1
    end
  end

  -- 二、快捷功能：按键徽标 + 自选字形 + 说明（与上一分区之间留一个空行）
  local items = key_plan.items or {}
  if #items > 0 then
    if mru_rows > 0 then
      newrow()
    end

    for _, entry in ipairs(items) do
      bar_row({
        badge = entry.key,
        badge_hl = hl.key,
        arrow_hl = hl.sep_key,
        icon = entry.item.icon,
        text = entry.item.desc,
        text_hl = hl.text,
      })
    end
  end

  -- 结尾的空行不渲染
  while #rows > 0 and #rows[#rows] == 0 do
    table.remove(rows)
  end
  return rows
end

-- ============================================================
-- 缓冲区 / 窗口 / 渲染
-- ============================================================

--- 显示 dashboard 的窗口（未打开 / 已失效时返回 nil）
--- @return integer|nil
local function dash_window()
  local buf = dash_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
  return nil
end

--- 取 dashboard 缓冲区（已失效时新建）：scratch + bufhidden = wipe
--- @return integer
local function ensure_buf()
  if dash_buf and vim.api.nvim_buf_is_valid(dash_buf) then
    return dash_buf
  end
  local buf = vim.api.nvim_create_buf(false, true) -- scratch：nofile + noswapfile
  vim.bo[buf].bufhidden = "wipe" -- 离开（打开文件 / 关闭）后自动清掉
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = cfg.filetype
  dash_buf = buf
  return buf
end

--- dashboard 窗口的局部选项：去掉行号 / 光标线 / 不可见字符等，保持「看板」观感
--- 两个要点：
---   1. 一律 scope = "local"：只改这个窗口，不动全局默认值 —— 否则以后新建的窗口 / 分割都会
---      继承 number = false、signcolumn = "no"，看起来就像「行号要 :set number 才出来」；
---   2. 改之前先把原值记进 saved_win_opts（每个窗口只记一次），离开 dashboard 时由
---      restore_stale_win_opts() 还原 —— dashboard 是「顶替当前窗口」，窗口还是原来那个。
--- @param win integer|nil
local function apply_win_opts(win)
  if type(win) ~= "number" or not vim.api.nvim_win_is_valid(win) then
    return
  end
  local opts = {
    number = false,
    relativenumber = false,
    cursorline = false,
    cursorcolumn = false,
    colorcolumn = "",
    signcolumn = "no",
    foldcolumn = "0",
    foldenable = false,
    list = false,
    wrap = false,
    spell = false,
    scrolloff = 0,
    sidescrolloff = 0,
    winbar = "",
  }
  if not saved_win_opts[win] then
    local snapshot = {}
    for name in pairs(opts) do
      local ok, value = pcall(vim.api.nvim_get_option_value, name, { win = win, scope = "local" })
      if ok then
        snapshot[name] = value
      end
    end
    saved_win_opts[win] = snapshot
  end
  for name, value in pairs(opts) do
    pcall(vim.api.nvim_set_option_value, name, value, { win = win, scope = "local" })
  end
end

--- 把一份「面板打开前的窗口局部选项」快照套回窗口
--- 注：'winbar' 不快照还原 —— 它由 custom.winbar 按 BufEnter 自己重设，还原成 "" 会把面包屑清掉
--- @param win integer|nil
--- @param snapshot table|nil
local function apply_snapshot(win, snapshot)
  if not snapshot or not (type(win) == "number" and vim.api.nvim_win_is_valid(win)) then
    return
  end
  for name, value in pairs(snapshot) do
    if name ~= "winbar" and value ~= nil then
      pcall(vim.api.nvim_set_option_value, name, value, { win = win, scope = "local" })
    end
  end
end

--- 还原某个窗口被 dashboard 改过的局部选项（没记录就什么都不做）
--- @param win integer|nil
local function restore_win_opts(win)
  if type(win) ~= "number" then
    return
  end
  local snapshot = saved_win_opts[win]
  if not snapshot then
    return
  end
  saved_win_opts[win] = nil
  apply_snapshot(win, snapshot)
end

--- 某个窗口当前是否还显示着 dashboard 缓冲区
--- @param win integer|nil
--- @return boolean
local function dashboard_shown_in(win)
  return dash_buf ~= nil
    and vim.api.nvim_buf_is_valid(dash_buf)
    and type(win) == "number"
    and vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_buf(win) == dash_buf
end

--- 把「已经不显示 dashboard」的窗口的局部选项还原回去
--- 关闭面板、从面板里直接打开文件、缓冲区被 bufhidden = wipe 清掉，都会走到这里（BufEnter 自动命令调用）
local function restore_stale_win_opts()
  for win in pairs(saved_win_opts) do
    if not dashboard_shown_in(win) then
      restore_win_opts(win)
    end
  end
end

--- 面板显示期间新建的普通窗口会继承面板窗口的局部选项（Vim 里分割本来就会继承当前窗口）：
--- 立刻改回面板打开前的值，免得新窗口也「没有行号」
--- （浮动窗口不碰：通知 / 诊断面板等自己管窗口选项）
local function normalize_new_window()
  if next(saved_win_opts) == nil then
    return
  end
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return -- 浮动窗口
  end
  for w, snapshot in pairs(saved_win_opts) do
    if dashboard_shown_in(w) then
      apply_snapshot(win, snapshot)
      return
    end
  end
end

--- 重绘 dashboard：重读历史文件 -> 重算键位 -> 重新写入内容与高亮
local function render()
  local buf = dash_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
    return
  end

  local win = dash_win
  if not (win and vim.api.nvim_win_is_valid(win)) or vim.api.nvim_win_get_buf(win) ~= buf then
    win = dash_window()
  end
  if not win then
    return
  end
  dash_win = win

  mru_cache = recent_files()
  key_plan = allocate_keys()

  local win_w = vim.api.nvim_win_get_width(win)
  local win_h = vim.api.nvim_win_get_height(win)
  local content_w = content_width(win_w) -- 窗口宽度的百分比（见 cfg.width）
  local rows = build_rows(content_w)

  -- 先铺满整屏空格，再把内容按水平居中 / 垂直居中摆进去
  local lines, marks = {}, {}
  local total_h = math.max(win_h, 1)
  for i = 1, total_h do
    lines[i] = ""
  end
  local top = math.max(0, math.floor((win_h - #rows) / 2))
  for i, chunks in ipairs(rows) do
    local left = math.max(0, math.floor((win_w - row_width(chunks)) / 2))
    local text = string.rep(" ", left)
    for _, chunk in ipairs(chunks) do
      marks[#marks + 1] = { row = top + i - 1, start = #text, finish = #text + #chunk.text, hl = chunk.hl }
      text = text .. chunk.text
    end
    lines[top + i] = text
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, mark in ipairs(marks) do
    if mark.hl then
      vim.api.nvim_buf_set_extmark(buf, ns, mark.row, mark.start, {
        end_col = mark.finish,
        hl_group = mark.hl,
      })
    end
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  pcall(vim.api.nvim_win_set_cursor, win, { math.min(total_h, top + 1), 0 })
end

--- 绑定面板内键位（每次打开 / 刷新都重建，以最新的分配结果为准）
--- @param buf integer|nil 缓冲区（nil / 已失效时什么都不做）
local function bind_keymaps(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  -- 清掉已经失效的缓冲区记录
  for bufnr in pairs(bound_maps) do
    if not vim.api.nvim_buf_is_valid(bufnr) then
      bound_maps[bufnr] = nil
    end
  end
  -- 先解绑上一次在这个缓冲区上绑的键位：改配置后重绑不会残留旧的一批
  for _, lhs in ipairs(bound_maps[buf] or {}) do
    pcall(vim.keymap.del, "n", lhs, { buffer = buf })
  end
  bound_maps[buf] = nil

  local plan = key_plan or {}
  local bound = {}
  local opts = { buffer = buf, silent = true, nowait = true }
  local function map(lhs, fn, desc)
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, fn, vim.tbl_extend("force", opts, { desc = desc }))
      bound[#bound + 1] = lhs
    end
  end

  for index, lhs in pairs(plan.digits or {}) do
    map(lhs, function()
      open_recent(index)
    end, "Dashboard: 打开第 " .. index .. " 条历史文件")
  end

  for _, entry in ipairs(plan.items or {}) do
    if entry.key then
      local item = entry.item
      map(item.key, function()
        run_action(item.action)
      end, "Dashboard: " .. item.desc)
    end
  end

  bound_maps[buf] = bound
end

--- 重读历史文件并重绘（未打开时什么都不做）
--- open() 每次都会走一遍这里的流程，所以不需要对外的 refresh
local function redraw()
  local win = dash_window()
  if not win then
    return
  end
  dash_win = win
  apply_win_opts(win)
  render()
  bind_keymaps(dash_buf)
end

-- ============================================================
-- 对外 API
-- ============================================================

--- 当前是否已打开 dashboard
--- @return boolean
function M.is_open()
  return dash_window() ~= nil
end

--- 打开 dashboard（已经打开时只聚焦 + 重读历史文件重绘，不再占用新窗口）
--- @return boolean 是否成功打开
function M.open()
  if #vim.api.nvim_list_uis() == 0 then
    return false -- 无 UI（headless / -es）时不打开
  end

  local buf = ensure_buf()

  -- 已经在别的窗口显示：先聚焦过去
  local shown = dash_window()
  if shown then
    pcall(vim.api.nvim_set_current_win, shown)
  end

  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= buf then
    prev_buf = vim.api.nvim_win_get_buf(win) -- 记下打开前的缓冲区，关闭时换回去
    local ok = pcall(vim.api.nvim_win_set_buf, win, buf)
    if not ok then
      vim.notify("dashboard：当前缓冲区有未保存的修改，先保存再打开", vim.log.levels.WARN)
      return false
    end
  end
  dash_win = win

  apply_win_opts(win)
  render()
  bind_keymaps(buf)
  return true
end

--- 关闭 dashboard：换回打开前的缓冲区（没有就新建一个空缓冲区）
function M.close()
  local buf = dash_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    dash_buf, dash_win, prev_buf = nil, nil, nil
    return
  end

  local target = prev_buf
  if not (target and vim.api.nvim_buf_is_valid(target) and vim.api.nvim_buf_is_loaded(target) and target ~= buf) then
    target = vim.api.nvim_create_buf(true, false) -- 没有可回的缓冲区：给一个空的普通缓冲区
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      pcall(vim.api.nvim_win_set_buf, win, target)
    end
  end

  restore_stale_win_opts() -- 还原窗口局部选项（不还原：该窗口会一直带着 number = false 等）

  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
  dash_buf, dash_win, prev_buf = nil, nil, nil
end

--- 退出 Neovim（面板内的退出键用它）
--- 有其他未保存的修改时只提示、不强退，避免把改动丢掉
function M.quit()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].modified then
      vim.notify(
        "dashboard：还有未保存的修改，先 :wa 保存（或 :qa! 强制退出）",
        vim.log.levels.WARN
      )
      return
    end
  end
  vim.cmd("qa")
end

--- 清空「最近文件」的历史记录（shada 里的 v:oldfiles）；面板上的清除键用它
--- 只清历史记录，不删任何文件；默认还会把「清空前用过的已打开文件」一起隐去，让面板真的空下来
--- @param opts table|nil { include_open = boolean 默认 true, persist = boolean 默认 true, notify = boolean 默认 true }
--- @return integer 清掉的历史记录条数
function M.clear_history(opts)
  opts = type(opts) == "table" and opts or {}
  local cleared = #(vim.v.oldfiles or {})

  -- 提示用：会被隐去的「已打开文件」条数（必须在设置清空时间点之前数）
  local hidden = 0
  if opts.include_open ~= false and (type(cfg.mru) ~= "table" or cfg.mru.open_buffers ~= false) then
    hidden = #open_buffers()
  end

  -- v:oldfiles 是面板读的历史记录：赋值清掉变量（面板立刻空），histdel 清掉 shada 里的那份
  pcall(function()
    vim.v.oldfiles = {}
  end)
  pcall(vim.fn.histdel, "v:oldfiles")

  if opts.include_open ~= false then
    cleared_before = os.time() -- 清空时间点：open_buffers() 只保留之后又用过的文件
  end

  if opts.persist ~= false and vim.o.shada ~= "" then
    -- 立刻写回 shada：不然下次启动又会从磁盘读回来
    pcall(function()
      vim.cmd("wshada!")
    end)
  end

  redraw() -- 面板开着就立刻刷新（关着时什么都不做）

  if opts.notify ~= false then
    local msg = string.format("dashboard：已清空最近文件历史（%d 条）", cleared)
    if hidden > 0 then
      msg = msg .. string.format("，并隐去 %d 个已打开的文件", hidden)
    end
    vim.notify(msg, vim.log.levels.INFO)
  end
  return cleared
end

--- 打开 / 关闭切换
function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

--- 重新应用自带配色（改了 colors / 切换主题后调用；setup() 内部也会调一次）
function M.apply_highlights()
  apply_highlights()
end

M.highlights = resolve_highlights

-- ============================================================
-- 命令 / 自动命令 / 配置入口
-- ============================================================

--- 注册 :Dashboard / :DashboardClose / :DashboardToggle
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true

  vim.api.nvim_create_user_command("Dashboard", function()
    M.open()
  end, { desc = "Dashboard: 打开（或聚焦）" })

  vim.api.nvim_create_user_command("DashboardClose", function()
    M.close()
  end, { desc = "Dashboard: 关闭" })

  vim.api.nvim_create_user_command("DashboardToggle", function()
    M.toggle()
  end, { desc = "Dashboard: 打开 / 关闭" })
end

--- 无参数启动且起始缓冲区为空时，自动显示 dashboard
local function maybe_autoload()
  if not cfg.autoload or #vim.api.nvim_list_uis() == 0 then
    return
  end
  if vim.fn.argc(-1) > 0 then
    return -- 带文件参数启动：不动
  end
  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].buftype ~= "" then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  if #lines > 1 or (lines[1] or "") ~= "" then
    return -- 起始缓冲区里已经有内容：不动
  end
  M.open()
end

--- 配置并启用（幂等：重复调用只重新合并配置 + 重新应用配色）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})

  -- 支持整体关闭的几项：归一化成后续代码可以直接用的形状
  if cfg.icons == false then
    cfg.icons = {} -- 图标字形不显示（色条箭头不受影响，见 arrow_glyph）
  end
  -- colors：预设名（"dark" / "light"）或覆盖表 -> 6 角色表（不写 / 写法不认识 / false 都按 dark）
  cfg.colors = resolve_colors(cfg.colors)
  if type(cfg.mru) ~= "table" then
    cfg.mru = { enable = false, limit = 0, cwd_only = false, open_buffers = false }
  end
  if type(cfg.shortcuts) ~= "table" then
    cfg.shortcuts = {}
  end
  cfg.width = math.max(10, math.min(100, tonumber(cfg.width) or DEFAULTS.width)) -- 窗口宽度的百分比

  apply_highlights()

  if initialized then
    redraw()
    return M
  end
  initialized = true

  local augroup = vim.api.nvim_create_augroup("custom_dashboard", { clear = true })

  -- 启动：VimEnter 之后（界面尺寸、shada 都已就绪）再显示
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    desc = "custom.dashboard: 无参数启动时显示 dashboard",
    callback = function()
      vim.schedule(maybe_autoload)
    end,
  })

  -- 终端尺寸变化后重排（水平 / 垂直居中依赖窗口大小）
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "custom.dashboard: 尺寸变化后重绘",
    callback = function()
      redraw()
    end,
  })

  -- 切换主题会清空高亮组：重新应用自带配色并重绘
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    desc = "custom.dashboard: 主题切换后重新应用配色",
    callback = function()
      apply_highlights()
      redraw()
    end,
  })

  -- 离开 dashboard（关闭 / 从面板里打开文件 / 缓冲区被清掉）后还原窗口局部选项：
  -- dashboard 是「顶替当前窗口」，不还原的话该窗口会一直带着 number = false、signcolumn = "no" 等
  vim.api.nvim_create_autocmd({ "BufEnter", "WinClosed" }, {
    group = augroup,
    desc = "custom.dashboard: 离开 dashboard 后还原窗口局部选项",
    callback = function()
      if next(saved_win_opts) ~= nil then
        restore_stale_win_opts()
      end
    end,
  })

  -- 面板显示期间新建的普通窗口不要继承面板观感（分割会继承当前窗口的局部选项）
  vim.api.nvim_create_autocmd("WinNew", {
    group = augroup,
    desc = "custom.dashboard: 面板显示期间新建的普通窗口改回正常选项",
    callback = normalize_new_window,
  })

  ensure_commands()

  return M
end

return M
