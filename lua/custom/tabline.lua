-- lua/custom/tabline.lua
-- 单条信息栏 tabline（标准插件写法：返回 M，由 M.setup() 生效）
-- 把 tabline 改成“一条占满整行的信息栏”，不再逐个显示 tab 标签：
--   开头一个装饰徽标 + 计数段（buffer / tab / window）+ 文件名段，段间用各自可配置的 Nerd Font 字形相连；
--   文件名段单独配色（默认深底白字），与计数段区分明显、清晰可辨。
--   示意（默认字形）：󰫢 󱀲 1 buf  󰓩 1 tab  󰖲 1 win  󰧮 file.lua 
--
-- 实现：把 'tabline' 设成 %! 表达式（见下方 TABLINE_EXPR），每次重绘时调用 M.render()。
--   参考 :h 'tabline'、:h statusline（"%!" 求值 与 %#高亮组# 的用法）。
--   表达式内写死了模块名，若重命名本文件需同步修改 TABLINE_EXPR。
--   颜色默认由本模块自带的高亮组提供（独立于配色方案），切换主题后会自动重新应用。
--
-- API：
--   require("custom.tabline").setup([opts])        合并配置并接管 tabline（幂等）
--   require("custom.tabline").render()             生成 tabline 字符串（供表达式调用）
--   require("custom.tabline").apply_highlights()   重新应用自带配色（切换主题后自动调用）
--   require("custom.tabline").restore()            还原本模块接管前的 'tabline'
--
-- 配置（M.setup(opts)）：
--   separator    string    "  "       兜底分隔符：分隔字形为空时使用
--   filename     string    "tail"     文件名显示："tail"（仅文件名）| "relative" | "absolute"
--   buffers      string    "listed"   buffer 计数："listed"（:ls 可见）| "all"（含未列出）
--   windows      string    "tabpage"  window 计数："tabpage"（当前标签页）| "all"（所有标签页）
--   labels = {                        各段标签文案（整体 false 或单项 "" 即不显示）
--     buffers = "buf", tabs = "tab", windows = "win",
--   }
--   icons = {                         各段字形（Nerd Font）；单项置 "" 去掉，整体 false 全去掉
--     lead       = "󰫢",  -- nf-md-star_four_points（开头的装饰徽标）
--     lead_cap   = "",  -- nf-pl-left_hard_divider（徽标 -> 计数段的过渡字形）
--     buffers    = "󱀲",  -- nf-md-file_multiple_outline
--     tabs       = "󰓩",  -- nf-md-tab
--     windows    = "󰖲",  -- nf-md-window_restore
--     filename   = "󰧮",  -- nf-md-file_document_outline
--     sep        = "",  -- nf-pl-left_soft_divider（计数段之间的分隔字形）
--     transition = "",  -- nf-pl-left_hard_divider（接文件名段的电源线过渡）
--     cap        = "",  -- nf-pl-left_hard_divider（文件名段末尾的收尾字形）
--   }
--   colors = {                        自带配色（独立于主题；整体设 false 则改用 highlight）
--     group    = "CustomTabline",     专用高亮组名前缀（Sep / Lead / Transition / Cap / Filename 派生自它）
--     lead     = { fg = "#7aa2f7", bg = "#1a1b26", bold = true }, -- 开头装饰徽标（默认由 bar 反色派生）
--     bar      = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }, -- 计数段：浅底深字
--     sep      = { fg = "#3d59a1", bg = "#7aa2f7" },              -- 分隔字形：同底偏暗
--     filename = { fg = "#ffffff", bg = "#3d59a1", bold = true }, -- 文件名段：深底白字
--     cap      = { fg = "#3d59a1", bg = "#7aa2f7" },              -- 末尾收尾字形（默认由 bar/filename 派生）
--   }
--   highlight    string    "TabLine"  colors = false 时使用的主题高亮组
--   fill         boolean   true       用空格补满整条 tabline（false 则只输出信息本身）
--   showtabline  boolean   true       setup 时设 showtabline = 2，保证单 tab 时也显示
--
-- 示例：
--   require("custom.tabline").setup()                     -- 全默认：图标 + 电源线分隔 + 自带配色
--   require("custom.tabline").setup({                     -- 换一套更醒目的配色（绿底深字）
--     colors = {
--       bar      = { fg = "#1a1b26", bg = "#9ece6a", bold = true },
--       sep      = { fg = "#3b6e2a", bg = "#9ece6a" },
--       filename = { fg = "#ffffff", bg = "#3b6e2a", bold = true },
--     },
--   })
--   require("custom.tabline").setup({                     -- 只换分隔字形（任意 Nerd Font 字形）
--     icons = { lead = "󰫢", lead_cap = "", sep = "", transition = "", cap = "" }, -- 当前默认值，可替换
--   })
--   require("custom.tabline").setup({                     -- 中文标签 + 相对路径 + 不补满
--     filename = "relative",
--     labels = { buffers = "缓冲", tabs = "标签", windows = "窗口" },
--     fill = false,
--   })
--   require("custom.tabline").setup({                     -- 关掉字形与自带配色，跟随主题
--     icons = false,
--     colors = false,
--     separator = " | ",
--     highlight = "TabLineSel",
--   })
--   require("custom.tabline").restore()                   -- 需要撤销时还原 'tabline'
local M = {}

--- 默认配置
local DEFAULTS = {
  separator = "  ", -- 兜底分隔符：分隔字形为空时使用
  filename = "tail", -- "tail" | "relative" | "absolute"
  buffers = "listed", -- "listed" | "all"
  windows = "tabpage", -- "tabpage" | "all"
  labels = {
    buffers = "buf",
    tabs = "tab",
    windows = "win",
  },
  icons = { -- Nerd Font 字形；单项置 "" 去掉，整体设 false 全去掉
    lead = "󰫢", -- nf-md-star_four_points：开头的装饰徽标（置 "" 关闭）
    lead_cap = "", -- nf-pl-left_hard_divider：徽标 -> 计数段的过渡字形（置 "" 关闭）
    buffers = "󱀲", -- nf-md-file_multiple_outline
    tabs = "󰓩", -- nf-md-tab
    windows = "󰖲", -- nf-md-window_restore
    filename = "󰧮", -- nf-md-file_document_outline
    sep = "", -- nf-pl-left_soft_divider：计数段之间的分隔字形
    transition = "", -- nf-pl-left_hard_divider：接文件名段的电源线过渡
    cap = "", -- nf-pl-left_hard_divider：文件名段末尾的收尾字形（置 "" 关闭）
  },
  colors = { -- 自带配色（独立于主题）；整体设 false 则改用 highlight
    group = "CustomTabline", -- 高亮组名前缀（Sep / Lead / Transition / Cap / Filename 派生自它）
    bar = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }, -- 计数段：浅底深字
    sep = { fg = "#3d59a1", bg = "#7aa2f7" }, -- 分隔字形：同底偏暗
    filename = { fg = "#ffffff", bg = "#3d59a1", bold = true }, -- 文件名段：深底白字
  },
  highlight = "TabLine", -- colors = false 时使用的主题高亮组
  fill = true, -- 用空格补满整条 tabline
  showtabline = true, -- setup 时设置 showtabline = 2
}

local cfg = vim.deepcopy(DEFAULTS)

local initialized = false -- setup() 是否已接管
local saved_tabline = nil -- 接管前的 'tabline'，供 M.restore() 还原

--- 'tabline' 的 %! 表达式：整条 tabline 交给 M.render() 求值
local TABLINE_EXPR = '%!v:lua.require("custom.tabline").render()'

--- tabline/statusline 里 % 是特殊字符，字面量需要写成 %%
--- @param s string
--- @return string
local function escape_percent(s)
  return (s:gsub("%%", "%%%%"))
end

--- buffer 数量：listed = :ls 可见的；all = 所有已创建的
--- @return integer
local function count_buffers()
  if cfg.buffers == "all" then
    return #vim.api.nvim_list_bufs()
  end
  return #vim.fn.getbufinfo({ buflisted = 1 })
end

--- window 数量：tabpage = 当前标签页；all = 所有标签页
--- @return integer
local function count_windows()
  if cfg.windows == "all" then
    return #vim.api.nvim_list_wins()
  end
  return #vim.api.nvim_tabpage_list_wins(0)
end

--- 当前文件名（缓冲区无名时用 [No Name]）
--- @return string
local function current_filename()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return "[No Name]"
  end
  if cfg.filename == "absolute" then
    return name
  end
  if cfg.filename == "relative" then
    return vim.fn.fnamemodify(name, ":~:.")
  end
  return vim.fn.fnamemodify(name, ":t")
end

--- 解析当前使用的高亮组
--- colors 为 table 时使用自带高亮组（独立于主题），并给分隔字形/过渡单独配色；
--- 否则统一使用 highlight 指定的主题高亮组（此时 sep / transition 为 nil）
--- @return { bar:string, sep:string|nil, transition:string|nil, cap:string|nil, file:string }
local function resolve_highlights()
  if type(cfg.colors) ~= "table" then
    local hl = cfg.highlight or "TabLine"
    return { bar = hl, sep = nil, lead = nil, lead_cap = nil, transition = nil, cap = nil, file = hl }
  end
  local base = cfg.colors.group or "CustomTabline"
  local has_file = type(cfg.colors.filename) == "table"
  return {
    bar = base,
    sep = base .. "Sep",
    lead = base .. "Lead",
    lead_cap = base .. "LeadCap",
    transition = has_file and (base .. "Transition") or nil,
    cap = has_file and (base .. "Cap") or nil,
    file = has_file and (base .. "Filename") or base,
  }
end

--- 取某个字形（"" 表示不显示）
--- @param name string "lead" | "lead_cap" | "buffers" | "tabs" | "windows" | "filename" | "sep" | "transition" | "cap"
--- @return string
local function icon_of(name)
  local icons = cfg.icons
  if type(icons) ~= "table" then
    return ""
  end
  local icon = icons[name]
  if type(icon) == "string" then
    return icon
  end
  return ""
end

--- 拼一段 "<icon> <count> <label>"，icon / label 为空时自动省略对应部分
--- @param icon string
--- @param count integer
--- @param label string
--- @return string
local function segment(icon, count, label)
  local out = tostring(count)
  if label ~= "" then
    out = out .. " " .. label
  end
  if icon ~= "" then
    out = icon .. " " .. out
  end
  return out
end

--- 生成 tabline 字符串（'tabline' 的 %! 表达式每次重绘都会调用它）
--- @return string
function M.render()
  local labels = type(cfg.labels) == "table" and cfg.labels or {}
  local hl = resolve_highlights()

  --- 取标签文案；nil 或非字符串一律按“不显示”处理
  local function label(name)
    local value = labels[name]
    if type(value) == "string" then
      return value
    end
    return ""
  end

  -- 先累积 { text, hl } 片段：后面要用未转义文本算显示宽度，再拼 %#高亮组#
  local chunks = {}
  local function push(text, group)
    if text ~= "" then
      chunks[#chunks + 1] = { text = text, hl = group }
    end
  end

  --- 段间分隔：优先用 Nerd Font 字形（左右各留一个空格），无字形时退回 separator 文本
  --- @param glyph string 分隔字形
  --- @param glyph_hl string 字形自身的高亮（如电源线过渡：前景=计数段底色）
  --- @param left_hl string 左侧空格的高亮（前一段底色）
  --- @param right_hl string 右侧空格的高亮（后一段底色）
  local function divider(glyph, glyph_hl, left_hl, right_hl)
    if glyph ~= "" then
      push(" ", left_hl)
      push(glyph, glyph_hl)
      push(" ", right_hl)
    else
      push(cfg.separator or "", left_hl)
    end
  end

  -- 开头装饰徽标：<空格><字形><空格> 用徽标配色，再用过渡三角切回计数段底色
  local lead_icon = icon_of("lead")
  if lead_icon ~= "" then
    local lead_hl = hl.lead or hl.bar
    push(" ", lead_hl)
    push(lead_icon, lead_hl)
    push(" ", lead_hl)
    -- 徽标 -> 计数段底色：字形由 icons.lead_cap 单独指定（前景 = 徽标底色，背景 = 计数段底色）
    push(icon_of("lead_cap"), hl.lead_cap or lead_hl)
    push(" ", hl.bar)
  end

  -- 计数段（buffer / tab / window），段间用分隔字形
  push(segment(icon_of("buffers"), count_buffers(), label("buffers")), hl.bar)
  divider(icon_of("sep"), hl.sep or hl.bar, hl.bar, hl.bar)
  push(segment(icon_of("tabs"), #vim.api.nvim_list_tabpages(), label("tabs")), hl.bar)
  divider(icon_of("sep"), hl.sep or hl.bar, hl.bar, hl.bar)
  push(segment(icon_of("windows"), count_windows(), label("windows")), hl.bar)

  -- 计数段 -> 文件名段：用电源线过渡字形（前景 = 计数段底色，背景 = 文件名段底色）
  divider(icon_of("transition"), hl.transition or hl.bar, hl.bar, hl.file)
  local file_icon = icon_of("filename")
  local filename = current_filename()
  push(file_icon ~= "" and (file_icon .. " " .. filename) or filename, hl.file)

  -- 文件名段末尾的收尾字形：与过渡相反，前景 = 文件名段底色，背景 = 计数段底色
  push(icon_of("cap"), hl.cap or hl.file)

  -- 填充宽度按未转义文本计算（%% 只占 1 列）
  local plain = {}
  for _, chunk in ipairs(chunks) do
    plain[#plain + 1] = chunk.text
  end
  local pad = 0
  if cfg.fill then
    pad = math.max(0, vim.o.columns - vim.fn.strdisplaywidth(table.concat(plain)))
  end

  -- 拼装：切高亮组，并把文本里的 % 转义成 %%
  local out = {}
  for _, chunk in ipairs(chunks) do
    out[#out + 1] = "%#" .. (chunk.hl or hl.bar) .. "#" .. escape_percent(chunk.text)
  end
  if pad > 0 then
    -- 填充空格用计数段配色，避免与文件名段背景不一致
    out[#out + 1] = "%#" .. hl.bar .. "#" .. string.rep(" ", pad)
  end
  return table.concat(out)
end

--- 应用自带配色（独立于主题；colors = false 时不做事）
--- 切换配色方案会清空高亮组，故由 ColorScheme 自动命令再次调用
function M.apply_highlights()
  if type(cfg.colors) ~= "table" then
    return
  end
  local base = cfg.colors.group or "CustomTabline"
  local bar = cfg.colors.bar or {}
  vim.api.nvim_set_hl(0, base, bar)
  -- 段间分隔字形：同底色 + 偏暗前景，形成层次
  vim.api.nvim_set_hl(0, base .. "Sep", cfg.colors.sep or { fg = bar.fg, bg = bar.bg })
  -- 开头装饰徽标：默认取计数段的反色（浅色字形 + 深色底）
  local lead = cfg.colors.lead or { fg = bar.bg, bg = bar.fg, bold = true }
  vim.api.nvim_set_hl(0, base .. "Lead", lead)
  -- 徽标 -> 计数段底色的过渡三角：前景 = 徽标底色，背景 = 计数段底色
  vim.api.nvim_set_hl(0, base .. "LeadCap", { fg = lead.bg, bg = bar.bg })
  if type(cfg.colors.filename) == "table" then
    local file = cfg.colors.filename
    vim.api.nvim_set_hl(0, base .. "Filename", file)
    -- 电源线过渡：前景 = 计数段底色，背景 = 文件名段底色
    vim.api.nvim_set_hl(0, base .. "Transition", { fg = bar.bg, bg = file.bg })
    -- 末尾收尾字形：与过渡相反，前景 = 文件名段底色，背景 = 计数段底色
    vim.api.nvim_set_hl(0, base .. "Cap", cfg.colors.cap or { fg = file.bg, bg = bar.bg })
  end
end

--- 注册自动命令（幂等）：主题切换后重新应用自带配色
local function ensure_autocmds()
  local augroup = vim.api.nvim_create_augroup("custom_tabline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = M.apply_highlights,
  })
end

--- 接管 tabline（幂等：重复调用只接管一次，但配置会刷新）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  opts = opts or {}
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts)
  -- 这几项支持整体设 false 关闭，这里显式赋值以免被当成“缺省”处理
  if opts.icons == false then
    cfg.icons = false
  end
  if opts.colors == false then
    cfg.colors = false
  end
  if opts.labels == false then
    cfg.labels = false
  end

  if initialized then
    return M
  end
  initialized = true

  -- 记住原值，便于 M.restore() 还原
  saved_tabline = vim.o.tabline

  -- 只有一个 tab 时默认不显示 tabline，必须为 2 才能看到信息条
  if cfg.showtabline then
    vim.o.showtabline = 2
  end

  M.apply_highlights()
  ensure_autocmds()
  vim.o.tabline = TABLINE_EXPR

  return M
end

--- 还原本模块接管前的 'tabline'，并移除本模块的自动命令
function M.restore()
  if saved_tabline ~= nil then
    vim.o.tabline = saved_tabline
    saved_tabline = nil
  end
  pcall(vim.api.nvim_del_augroup_by_name, "custom_tabline")
  initialized = false
end

return M

