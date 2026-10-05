-- lua/custom/dashboard.lua
-- 启动仪表盘（Neovim 原生 API 实现；标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
-- 两个功能：
--   1. 历史文件快速进入：列出 v:oldfiles（shada 里的最近文件，只保留仍可读的真实文件），
--      数字键 1..9（第 10 条为 0）直接打开，不必先跳去文件树或查找器；
--   2. 自定义快捷功能：shortcuts 配置项，每项 { icon, key, desc, action }，
--      action 是函数就直接调用，是字符串就当 :命令 执行，按键即触发。
-- 外观（powerline 风格；没有标题、没有分割线、没有分区标题）：
--   * 每条都是铺满固定宽度的「色条」：底色贯通整行，行尾用 Nerd Font 箭头收口；
--       [ 序号 / 按键徽标 ]▏ 图标 文件名 ……… 所在目录▏
--   * 序号（历史文件）与按键（快捷功能）用不同颜色的徽标区分，徽标后紧跟一个过渡
--     箭头接到色条底色 —— 一眼就能看出「按哪个键」，不必再写「历史文件 / 快捷功能」；
--   * 配色是本模块自带的（不依赖主题），切换主题后自动重新应用；
--     colors = false 时只显示文字（不画色条 / 箭头），并改用主题高亮组。
--
-- 布局：
--   * 用一个 scratch buffer 顶替当前窗口的内容（filetype = <cfg.filetype>，默认 "dashboard"），
--     所以 custom.winbar 不会画面包屑、custom.diagnostics 不会弹面板；
--   * 内容水平居中、垂直居中，窗口尺寸变化时自动重排；
--   * 打开文件（历史文件 / 快捷功能）时，dashboard 缓冲区按 bufhidden = wipe 自动清掉；
--     q / <Esc> / <C-c> 关闭 dashboard 时，换回打开前的那个缓冲区。
--
-- API：
--   require("custom.dashboard").setup([opts])        合并配置 + 注册命令 / 可选键位 / 自动命令（幂等）
--   require("custom.dashboard").open()               打开（或聚焦）dashboard
--   require("custom.dashboard").close()              关闭（换回打开前的缓冲区）
--   require("custom.dashboard").quit()               退出 Neovim（有未保存的修改时只提示）
--   require("custom.dashboard").toggle()             打开 / 关闭切换
--   require("custom.dashboard").refresh()            重读历史文件并重绘
--   require("custom.dashboard").is_open()            当前是否已打开
--   require("custom.dashboard").apply_highlights()   重新应用自带配色（切换主题后会自动调用）
--   require("custom.dashboard").highlights()         取各角色当前使用的高亮组名（调试 / 自定义用）
--
-- 用户命令：
--   :Dashboard  :DashboardClose  :DashboardToggle  :DashboardRefresh
--
-- 面板内默认键位（打开时绑定，可在配置里改或置 "" 取消；map_keys = false 时一个都不绑）：
--   q                  退出 Neovim（有其他未保存的修改时只提示、不强退）
--   <Esc> / <C-c>      关闭 dashboard（换回打开前的缓冲区；<C-c> 是固定别名）
--   R                  重读历史文件并重绘
--   1..9 / 0           打开第 1..10 条历史文件（条数不足时对应键不生效）
--   shortcuts 里各自的 key  执行对应动作（与上面的键冲突时忽略，见「键位分配」）
--   提示：dashboard 是 nomodifiable 的，编辑类按键会报 E21，这是预期行为（用 <Esc> 关闭 / q 退出）。
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   autoload   boolean  true      无参数启动（nvim 后不带文件名、起始缓冲区为空）时自动显示
--   disable_filetype table  {}    这些 filetype 不自动显示 dashboard（只影响 autoload：
--                                 显式 :Dashboard / 键位都不受影响）；本模块自己的排除列表，
--                                 与 custom.diagnostics / custom.lsp 的 disable_filetypes 无关
--   width      number   62        内容宽度（列）= 每条色条的固定宽度，窗口太窄时自动收窄
--   mru = {                       历史文件（v:oldfiles）
--     enable   boolean  true      是否显示该分区
--     limit    number   9         最多显示几条（> 9 的部分只展示、不给按键）
--     cwd_only boolean  false     true = 只显示当前工作目录下的文件
--   }
--   shortcuts = {                 自定义快捷功能
--     { icon = "󰚰", key = "u", desc = "更新插件", action = function() vim.pack.update() end },
--     { icon = "󰈞", key = "f", desc = "查找文件", action = "FzfLua files" },
--   }
--   icons = {                     各处的 Nerd Font 字形（整体设 false 则这些字形全部不显示）
--     sep    = nr2char(0xE0B0)   徽标 -> 色条、色条 -> 行尾收口用的 powerline 右箭头（默认值；置 "" 则不画箭头）
--     file   = 字形              文件字形（所有文件都用它；置 "" 则不显示）
--     footer = 字形              页脚字形（置 "" 则不显示）
--   }
--   labels = {                    文案（"" 表示不显示；footer = nil 时按当前键位自动生成）
--     empty_mru = "暂无历史文件", footer = nil,
--   }
--   colors = { ... }              自带高对比配色（整体设 false 则改用 highlight 里的主题高亮组）
--                                 核心是 bar（整行色条底色）：色条内其它角色没写 bg 时自动继承它；
--                                 index / key 是两种徽标的底色，tail（行尾箭头）的字色自动取 bar 的底色
--   highlight = { ... }           colors = false 时各角色使用的主题高亮组（此时不画色条 / 箭头）
--   keys = {                      面板内键位（置 "" 取消）
--     quit = "q", close = "<Esc>", refresh = "R", open = "",
--   }
--   map_keys   boolean  true      是否绑定本模块负责的全部键位：
--                                 true  = 面板内键位（quit / close / refresh / 数字键 / 快捷功能）
--                                         + keys.open（普通模式，打开 / 关闭 dashboard）；
--                                 false = 一个键都不绑，只用 :Dashboard* 命令，
--                                         面板上也不再显示按键徽标与键位提示
--   filetype   string   "dashboard"  dashboard 缓冲区的 filetype
--
-- 键位分配：内置键（退出 / 关闭 / 刷新）最先占用，其次 shortcuts，最后才是历史文件的数字键；
-- 冲突的一方直接忽略（只展示、不给按键），不会出现一个键绑两个功能。
-- keys.open 是普通模式的全局键位，默认 ""（不绑），同样由 map_keys 控制；
-- 想绑就自己挑一个没被占用的键，例如 keys = { open = "<leader>fo" }。
--
-- 示例：
--   require("custom.dashboard").setup()                          -- 全默认
--   require("custom.dashboard").setup({ mru = { limit = 12 } })  -- 多列几条历史文件
--   require("custom.dashboard").setup({ map_keys = false })      -- 一个键都不绑（只用 :Dashboard* 命令）
--   require("custom.dashboard").setup({ disable_filetype = { "markdown" } }) -- 这些类型不自动显示
--   require("custom.dashboard").setup({                          -- 换掉快捷功能列表
--     shortcuts = {
--       { icon = "󰈞", key = "f", desc = "查找文件", action = "FzfLua files" },
--       { icon = "", key = "e", desc = "文件树", action = "Neotree filesystem toggle" },
--     },
--   })
--   require("custom.dashboard").setup({ colors = false })        -- 配色跟随主题
-- ============================================================

local M = {}

--- 默认配置
local DEFAULTS = {
  autoload = true, -- 无参数启动时自动显示
  disable_filetype = {}, -- 这些 filetype 不自动显示（只影响 autoload；本模块自己的排除列表）
  width = 62, -- 内容宽度（列）
  mru = { -- 历史文件（v:oldfiles）
    enable = true,
    limit = 9, -- 最多显示几条（> 9 的部分只展示、不给按键）
    cwd_only = false,
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
    { icon = "󰋚", key = "h", desc = "history", action = "FzfLua oldfiles" },
  },
  icons = { -- 各处的 Nerd Font 字形（整体设 false 则这些字形全部不显示）
    sep = vim.fn.nr2char(0xe0b0), -- 徽标 -> 色条、色条 -> 行尾收口的 powerline 右箭头 U+E0B0（"" 不画箭头）
    file = "󰧮", -- 文件字形（所有文件都用它；置 "" 则不显示）
    footer = "󰌌", -- 页脚
  },
  labels = { -- 文案（"" 表示不显示）
    empty_mru = "暂无历史文件",
    footer = nil, -- nil = 按当前键位自动生成提示
  },
  colors = { -- 自带高对比配色（不依赖主题；整体设 false 则改用 highlight 里的主题高亮组）
    group = "CustomDashboard", -- 自带高亮组名前缀
    normal = nil, -- 想让 dashboard 窗口自带底色时给 { fg = ..., bg = ... }
    bar = { fg = "#c0caf5", bg = "#292e42" }, -- 整行色条的底色（下面各角色没写 bg 时自动继承它）
    index = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }, -- 历史文件序号徽标：亮蓝底深字
    key = { fg = "#1a1b26", bg = "#e0af68", bold = true }, -- 快捷功能按键徽标：亮黄底深字
    icon = { fg = "#ff9e64", bold = true }, -- 行内字形：亮橙
    desc = { fg = "#c0caf5" }, -- 说明文字
    file = { fg = "#ffffff", bold = true }, -- 文件名：亮白加粗
    dir = { fg = "#7f86ad" }, -- 文件所在目录
    empty = { fg = "#7f86ad", italic = true }, -- 空列表提示
    footer = { fg = "#8a91b4" }, -- 页脚（不在色条里，所以不继承 bar 的底色）
    tail = {}, -- 行尾收口箭头：字色自动取 bar 的底色，不用手写
  },
  highlight = { -- colors = false 时各角色使用的主题高亮组（nil = 用下面的默认值；不画色条 / 箭头）
    normal = nil,
    icon = "Special",
    index = "Constant",
    key = "Identifier",
    desc = "Normal",
    file = "Directory",
    dir = "Comment",
    empty = "Comment",
    footer = "Comment",
  },
  keys = { -- 面板内键位（"" 取消）
    quit = "q", -- 退出 Neovim（有其他未保存的修改时只提示、不强退）
    close = "<Esc>", -- 关闭 dashboard（<C-c> 是固定别名，不受此项影响）
    refresh = "R", -- 重读历史文件并重绘
    open = "", -- 普通模式：打开 / 关闭 dashboard（默认不绑，避免占用别人的键）
  },
  map_keys = true, -- 是否绑定本模块的全部键位（false = 一个都不绑，只用 :Dashboard* 命令）
  filetype = "dashboard", -- dashboard 缓冲区的 filetype（custom.winbar / custom.diagnostics 已按它排除）
}

-- 本模块自带的配色角色（apply_highlights 按此批量设置高亮组）
local COLOR_ROLES = { "normal", "bar", "index", "key", "icon", "desc", "file", "dir", "empty", "footer", "tail" }

--- 这个角色是不是画在色条里（是的话没写 bg 时自动继承 bar 的底色，色条才不会在行中间断色）
--- @param role string
--- @return boolean
local function inside_bar(role)
  return role ~= "normal" and role ~= "bar" and role ~= "footer" and role ~= "tail"
end

local cfg = vim.deepcopy(DEFAULTS)

local initialized = false -- setup() 是否已完成注册
local commands_created = false -- 用户命令是否已注册
local open_lhs = nil -- 已绑定的 keys.open（改配置后据此解绑 / 重绑）

local dash_buf = nil -- dashboard 缓冲区
local dash_win = nil -- dashboard 所在窗口
local prev_buf = nil -- 打开 dashboard 前该窗口里的缓冲区（关闭时换回去）
local mru_cache = {} -- 最近一次渲染出的历史文件（数字键据此打开）
local key_plan = {} -- 最近一次渲染算出的键位分配（渲染与绑键位共用）
local bound_maps = {} -- [bufnr] = 该缓冲区上绑过的键位（重绑前先解绑，改配置后不残留）

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

--- 取一段文案（缺失 / 非字符串都按「不显示」处理）
--- @param name string
--- @return string
local function label_of(name)
  local labels = cfg.labels
  if type(labels) ~= "table" then
    return ""
  end
  local value = labels[name]
  return type(value) == "string" and value or ""
end

-- ============================================================
-- 高亮（默认自带一套高对比配色，不依赖主题）
-- ============================================================

--- 各角色使用的高亮组名
--- colors 为 table 时用本模块自带的高亮组；
--- colors = false 时退回 highlight 里的主题高亮组（其中每项都可直接改）
--- @return table<string, string|nil>
local function resolve_highlights()
  if type(cfg.colors) ~= "table" then
    local hl = type(cfg.highlight) == "table" and cfg.highlight or {}
    return {
      normal = hl.normal,
      bar = nil, -- 没有自带配色：不画色条底色，只显示文字
      icon = hl.icon or "Special",
      index = hl.index or "Constant",
      key = hl.key or "Identifier",
      desc = hl.desc or "Normal",
      file = hl.file or "Directory",
      dir = hl.dir or "Comment",
      empty = hl.empty or "Comment",
      footer = hl.footer or "Comment",
      tail = nil, -- tail 为 nil 时不画收口箭头
      sep_index = nil,
      sep_key = nil,
    }
  end

  local base = cfg.colors.group or "CustomDashboard"
  return {
    normal = cfg.colors.normal and (base .. "Normal") or nil,
    bar = base .. "Bar",
    icon = base .. "Icon",
    index = base .. "Index",
    key = base .. "Key",
    desc = base .. "Desc",
    file = base .. "File",
    dir = base .. "Dir",
    empty = base .. "Empty",
    footer = base .. "Footer",
    tail = base .. "Tail",
    sep_index = base .. "SepIndex", -- 序号徽标 -> 色条 的过渡箭头
    sep_key = base .. "SepKey", -- 按键徽标 -> 色条 的过渡箭头
  }
end

--- 应用自带配色（colors = false 时什么都不做）
--- 切换配色方案会清空高亮组，所以由 ColorScheme 自动命令再次调用
local function apply_highlights()
  if type(cfg.colors) ~= "table" then
    return
  end
  local groups = resolve_highlights()
  local bar_bg = type(cfg.colors.bar) == "table" and cfg.colors.bar.bg or nil
  if type(bar_bg) ~= "string" then
    bar_bg = nil
  end

  for _, role in ipairs(COLOR_ROLES) do
    local spec = cfg.colors[role]
    local group = groups[role]
    if type(spec) == "table" and type(group) == "string" then
      local out = vim.deepcopy(spec)
      if role == "tail" then
        out.fg = out.fg or bar_bg -- 收口箭头：字色 = 色条底色
      elseif bar_bg and inside_bar(role) then
        out.bg = out.bg or bar_bg -- 色条内的角色：没写 bg 就补上色条底色
      end
      vim.api.nvim_set_hl(0, group, out)
    end
  end

  -- 徽标 -> 色条 的过渡箭头：字色 = 徽标底色，底色 = 色条底色
  for badge_role, sep_role in pairs({ index = "sep_index", key = "sep_key" }) do
    local badge = cfg.colors[badge_role]
    local group = groups[sep_role]
    if bar_bg and type(badge) == "table" and type(badge.bg) == "string" and type(group) == "string" then
      vim.api.nvim_set_hl(0, group, { fg = badge.bg, bg = bar_bg })
    end
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

--- 历史文件：v:oldfiles 里仍然可读的真实文件（去重，保持最近使用顺序）
--- @return string[] 绝对路径
local function recent_files()
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  local limit = math.max(0, tonumber(mru.limit) or 0)
  local cwd = mru.cwd_only and (vim.fn.getcwd() .. "/") or nil
  local out, seen = {}, {}
  for _, path in ipairs(vim.v.oldfiles or {}) do
    if #out >= limit then
      break
    end
    if type(path) == "string" and path ~= "" and vim.fn.filereadable(path) == 1 then
      local full = vim.fn.fnamemodify(path, ":p")
      local key = real_path(full)
      if not seen[key] and (not cwd or vim.fn.stridx(full, cwd) == 0) then
        seen[key] = true
        out[#out + 1] = full
      end
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

--- 键位分配：内置键（关闭 / 刷新）最先占用，其次 shortcuts，最后才是历史文件的数字键；
--- 冲突的一方被忽略（只展示、不给按键），不会出现一个键绑两个功能
--- 注意：数字键的分配依赖 mru_cache，所以必须在 recent_files() 之后调用
--- @return table
local function allocate_keys()
  local keys = type(cfg.keys) == "table" and cfg.keys or {}
  -- map_keys = false：一个键都不绑（快捷功能仍然列出，只是不给按键徽标）
  if not cfg.map_keys then
    local items = {}
    for _, item in ipairs(shortcut_items()) do
      items[#items + 1] = { item = item }
    end
    return { items = items, digits = {} }
  end
  local used = { ["<C-c>"] = true } -- 关闭键的固定别名，不允许被占用

  --- 占用一个键位；已被占用 / 为空则返回 nil
  local function claim(lhs)
    if type(lhs) ~= "string" or lhs == "" or used[lhs] then
      return nil
    end
    used[lhs] = true
    return lhs
  end

  local quit = claim(keys.quit)
  local close = claim(keys.close)
  local refresh = claim(keys.refresh)

  local items = {}
  for _, item in ipairs(shortcut_items()) do
    items[#items + 1] = { item = item, key = claim(item.key) }
  end

  local digits = {}
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  if mru.enable then
    for index = 1, #mru_cache do
      local lhs = mru_key(index)
      if lhs then
        digits[index] = claim(lhs)
      end
    end
  end

  return { quit = quit, close = close, refresh = refresh, items = items, digits = digits }
end

-- ============================================================
-- 生成内容
-- ============================================================

--- 生成 dashboard 的每一行（{ text, hl } 片段数组），每行都不超过 width 列
--- @param width integer 内容宽度（列）
--- @return table[]
local function build_rows(width)
  local hl = resolve_highlights()
  local rows = {}
  local cur = nil

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

  --- 当前行还能放多少列
  --- @return integer
  local function remaining()
    return math.max(0, width - row_width(cur))
  end

  -- 段与段之间的过渡 / 行尾收口：powerline 右箭头（只有自带配色时才画）
  local arrow = (hl.tail and icon_of("sep")) or ""
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

  -- 一、历史文件：序号徽标 + 文件字形 + 文件名 + 所在目录
  local mru = type(cfg.mru) == "table" and cfg.mru or {}
  local mru_enable = mru.enable == true
  if mru_enable then
    if #mru_cache == 0 then
      bar_row({ text = label_of("empty_mru"), text_hl = hl.empty })
    else
      for index, path in ipairs(mru_cache) do
        bar_row({
          badge = key_plan.digits and key_plan.digits[index],
          badge_hl = hl.index,
          arrow_hl = hl.sep_index,
          icon = icon_of("file"),
          text = vim.fn.fnamemodify(path, ":t"),
          text_hl = hl.file,
          right = vim.fn.fnamemodify(path, ":~:h"),
          right_hl = hl.dir,
        })
      end
    end
  end

  -- 二、快捷功能：按键徽标 + 自选字形 + 说明（与上一分区之间留一个空行）
  local items = key_plan.items or {}
  if #items > 0 then
    if mru_enable then
      newrow()
    end

    for _, entry in ipairs(items) do
      bar_row({
        badge = entry.key,
        badge_hl = hl.key,
        arrow_hl = hl.sep_key,
        icon = entry.item.icon,
        text = entry.item.desc,
        text_hl = hl.desc,
      })
    end
  end

  -- 页脚：按当前键位自动生成提示，也可以直接用 labels.footer 覆盖
  local footer = type(cfg.labels) == "table" and cfg.labels.footer or nil
  if type(footer) ~= "string" then
    local hints = {}
    if not cfg.map_keys then
      -- 没绑键位：提示命令（按键提示一个都不显示，免得提示了按不到）
      hints[#hints + 1] = "键位未绑定（map_keys = false）"
      hints[#hints + 1] = ":DashboardClose 关闭"
    else
      if mru_enable and #mru_cache > 0 then
        hints[#hints + 1] = "数字键 打开文件"
      end
      if key_plan.close then
        hints[#hints + 1] = key_plan.close .. " 关闭"
      end
      if key_plan.quit then
        hints[#hints + 1] = key_plan.quit .. " 退出"
      end
      if key_plan.refresh then
        hints[#hints + 1] = key_plan.refresh .. " 刷新"
      end
    end
    -- 窄窗口里按可用宽度挑能放下的提示，整条丢弃而不是砍半个
    local footer_icon = icon_of("footer")
    local budget = width - (footer_icon ~= "" and (text_width(footer_icon) + 1) or 0)
    footer = ""
    for _, hint in ipairs(hints) do
      local candidate = footer == "" and hint or (footer .. " · " .. hint)
      if text_width(candidate) > budget then
        break
      end
      footer = candidate
    end
  end
  if footer ~= "" then
    newrow() -- 空行（与上一分区分隔）
    newrow()
    local icon = icon_of("footer")
    if icon ~= "" then
      add(icon .. " ", hl.footer) -- 页脚不在色条里，字形跟着页脚走
    end
    add(truncate_tail(footer, remaining()), hl.footer)
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
--- @param win integer|nil
local function apply_win_opts(win)
  if type(win) ~= "number" or not vim.api.nvim_win_is_valid(win) then
    return
  end
  local hl = resolve_highlights()
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
    winhighlight = hl.normal and ("Normal:" .. hl.normal) or "",
  }
  for name, value in pairs(opts) do
    pcall(vim.api.nvim_set_option_value, name, value, { win = win })
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
  local content_w = math.max(10, math.min(cfg.width, win_w - 4))
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
--- map_keys = false 时一个键都不绑（并把上一次绑过的清掉）
--- @param buf integer
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
  if not cfg.map_keys then
    return
  end

  local plan = key_plan or {}
  local bound = {}
  local opts = { buffer = buf, silent = true, nowait = true }
  local function map(lhs, fn, desc)
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, fn, vim.tbl_extend("force", opts, { desc = desc }))
      bound[#bound + 1] = lhs
    end
  end

  map(plan.quit, M.quit, "Dashboard: 退出 Neovim")
  map(plan.close, M.close, "Dashboard: 关闭")
  map("<C-c>", M.close, "Dashboard: 关闭（固定别名）")
  map(plan.refresh, render, "Dashboard: 刷新")

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

-- ============================================================
-- 对外 API
-- ============================================================

--- 当前是否已打开 dashboard
--- @return boolean
function M.is_open()
  return dash_window() ~= nil
end

--- 打开 dashboard（已经打开时只聚焦 + 重绘，不再占用新窗口）
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
      vim.notify("dashboard：还有未保存的修改，先 :wa 保存（或 :qa! 强制退出）", vim.log.levels.WARN)
      return
    end
  end
  vim.cmd("qa")
end

--- 打开 / 关闭切换
function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

--- 重读历史文件并重绘（没打开时什么都不做）
function M.refresh()
  if not M.is_open() then
    return
  end
  if type(dash_win) == "number" and vim.api.nvim_win_is_valid(dash_win) then
    apply_win_opts(dash_win)
  end
  render()
  bind_keymaps(dash_buf)
end

--- 重新应用自带配色（colors = false 时为空操作）
function M.apply_highlights()
  apply_highlights()
end

M.highlights = resolve_highlights

-- ============================================================
-- 命令 / 自动命令 / 配置入口
-- ============================================================

--- 注册 :Dashboard / :DashboardClose / :DashboardToggle / :DashboardRefresh
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

  vim.api.nvim_create_user_command("DashboardRefresh", function()
    M.refresh()
  end, { desc = "Dashboard: 重读历史文件并重绘" })
end

--- 可选：绑定 keys.open 打开 / 关闭 dashboard（同样由 map_keys 控制）
--- 按最新配置解绑 / 重绑：换了键就解绑旧的，置 "" 或 map_keys = false 就解绑
local function ensure_keymaps()
  local keys = type(cfg.keys) == "table" and cfg.keys or {}
  local lhs = cfg.map_keys and keys.open or nil
  if type(lhs) ~= "string" or lhs == "" then
    lhs = nil
  end
  if lhs == open_lhs then
    return
  end
  if open_lhs then
    pcall(vim.keymap.del, "n", open_lhs)
  end
  open_lhs = lhs
  if lhs then
    vim.keymap.set("n", lhs, function()
      M.toggle()
    end, { silent = true, desc = "Dashboard: 打开 / 关闭" })
  end
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
  if vim.tbl_contains(cfg.disable_filetype or {}, vim.bo[buf].filetype) then
    return -- 当前 filetype 在 disable_filetype 里：不自动显示
  end
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
    cfg.icons = {}
  end
  if type(cfg.disable_filetype) ~= "table" then
    cfg.disable_filetype = {}
  end
  if type(cfg.mru) ~= "table" then
    cfg.mru = { enable = false, limit = 0, cwd_only = false }
  end
  if type(cfg.shortcuts) ~= "table" then
    cfg.shortcuts = {}
  end
  if type(cfg.labels) ~= "table" then
    cfg.labels = {}
  end
  if type(cfg.keys) ~= "table" then
    cfg.keys = vim.deepcopy(DEFAULTS.keys)
  end
  cfg.width = math.max(10, tonumber(cfg.width) or DEFAULTS.width)

  apply_highlights()

  if initialized then
    ensure_keymaps()
    M.refresh()
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
      M.refresh()
    end,
  })

  -- 切换主题会清空高亮组：重新应用自带配色并重绘
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    desc = "custom.dashboard: 主题切换后重新应用配色",
    callback = function()
      apply_highlights()
      M.refresh()
    end,
  })

  ensure_commands()
  ensure_keymaps()

  return M
end

return M
