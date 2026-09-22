-- ============================================================
-- 浮动通知：用浮动窗口替代 Neovim 默认的 vim.notify 实现
-- ------------------------------------------------------------
-- 特点：
--   * 接管 vim.notify（保留原生实现、可 restore）：仓库里现有调用点
--     （custom.diagnostics / autopair / terminal / winbar、plugins.mason）自动换成浮动提示；
--   * 边框按等级着色（TRACE/DEBUG/INFO/WARN/ERROR），无图标、无标题文字，简约为主；
--   * 默认「右下、贴状态栏上方」，自动避开 tabline / winbar / statusline / 命令行；
--     多条通知「新的靠锚点、旧的向内推」纵向堆叠，超出 max_visible 或可用高度时丢弃最旧；
--   * 按等级自动关闭（ERROR 默认常驻）；终端尺寸变化后自动重排；
--   * opts.kind == "progress" 的通知原地更新（同 kind + source/title 视为同一条），不刷屏；
--   * 停用（enabled = false）或无 UI（headless / -es）时透传原生实现，不影响脚本与测试。
--
-- API：
--   require("custom.notify").setup([opts])                 合并配置并接管 vim.notify（幂等）
--   require("custom.notify").notify(msg[, level[, opts]])  等价于接管后的 vim.notify
--   require("custom.notify").clear()                       关闭全部浮动通知
--   require("custom.notify").enable() / disable() / toggle()
--   require("custom.notify").restore()                     还原原生 vim.notify（并关闭浮动窗口）
--
-- 用户命令：
--   :NotifyTest [level]   发一条测试通知；level 可为 trace/debug/info/warn/error（默认 info）
--   :NotifyClose          关闭全部浮动通知
--   :NotifyToggle         启用 / 停用浮动通知
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   enabled     boolean    true                  是否接管 vim.notify（false = 完全透传原生实现）
--   position    string     "bottomright"         锚点：bottomright | bottomleft | topright | topleft
--   margin      table      { row = 0, col = 0 }  距可用区边缘的额外内缩（行 / 列）
--   border      string     "rounded"             边框：rounded | single | double | solid | shadow |
--                                                none（也支持 nvim_open_win 的 8 元素自定义表）
--   min_width   number     30                    最小内容宽度（不含边框）
--   max_width   number     80                    最大内容宽度（不超过 columns - margin.col * 2）
--   max_height  number     15                    最大内容高度（超出截断并在末行补 "…"）
--   max_visible number     3                     同时最多显示几条（超出丢弃最旧的）
--   winblend    number     0                     浮动窗口透明度（0 = 不透明）
--   zindex      number     50                    浮动窗口层级
--   title       boolean    false                 是否在边框上居中显示等级文字（如 WARN）
--   history     boolean    false                 true = 额外写入 :messages（命令行区会出现一行文本）
--   timeout     table      按等级自动关闭（毫秒，0 = 常驻）：
--                { TRACE = 2000, DEBUG = 2000, INFO = 3000, WARN = 5000, ERROR = 0 }
--   colors      table|false                    等级边框色；colors = false 时跟随主题的 FloatBorder
--                { group = "CustomNotify", border = { ERROR = "#FF6B6B", ... }, normal = nil }
--                normal 给定时，额外用 <group>Normal 覆盖正文配色
--
-- 示例：
--   require("custom.notify").setup()                    -- 全默认
--   require("custom.notify").setup({                    -- 左下 + 双线框 + 自定义等级色
--     position = "bottomleft",
--     border = "double",
--     colors = { border = { ERROR = "#e06c75", WARN = "#e5c07b" } },
--   })
--   require("custom.notify").setup({ enabled = false })  -- 只用原生 vim.notify
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  enabled = true,
  position = "bottomright",
  margin = { row = 0, col = 0 },
  border = "rounded",
  min_width = 30,
  max_width = 80,
  max_height = 15,
  max_visible = 3,
  winblend = 0,
  zindex = 50,
  title = false,
  history = false,
  timeout = { TRACE = 2000, DEBUG = 2000, INFO = 3000, WARN = 5000, ERROR = 0 },
  colors = {
    group = "CustomNotify",
    border = {
      ERROR = "#FF6B6B",
      WARN = "#FFD93D",
      INFO = "#6BCB77",
      DEBUG = "#9AA5B1",
      TRACE = "#6C7086",
    },
    normal = nil,
  },
}

local cfg = vim.deepcopy(DEFAULTS)
local initialized = false
local orig_notify = vim.notify -- 接管前的实现（停用 / 无 UI 时透传）

--- 等级编号 <-> 名称（vim.log.levels 只有 TRACE / DEBUG / INFO / WARN / ERROR / OFF）
local LEVEL_NAMES = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}
local LEVEL_ORDER = { "ERROR", "WARN", "INFO", "DEBUG", "TRACE" }

--- 当前显示的浮动通知（按创建顺序，末位最新）
--- @type table[]
local active = {}

--- 等级名（未知等级按 INFO 处理）
--- @param level integer|nil
--- @return string
local function level_name(level)
  return LEVEL_NAMES[level or vim.log.levels.INFO] or "INFO"
end

--- 把通知内容归一化成字符串（vim.notify 约定为 string，这里对 table 做兜底）
--- @param msg string|table
--- @return string
local function to_text(msg)
  if type(msg) == "table" then
    return table.concat(vim.tbl_map(tostring, msg), "\n")
  end
  return tostring(msg)
end

--- 按显示宽度折行（strdisplaywidth 可正确处理中文 / 宽字符）
--- @param text string
--- @param width integer
--- @return string[]
local function wrap(text, width)
  local out = {}
  for _, raw in ipairs(vim.split(text, "\n", { plain = true })) do
    if raw == "" then
      out[#out + 1] = ""
    else
      local line = ""
      for _, ch in ipairs(vim.fn.split(raw, "\\zs")) do
        if line ~= "" and vim.fn.strdisplaywidth(line .. ch) > width then
          out[#out + 1] = line
          line = ch
        else
          line = line .. ch
        end
      end
      out[#out + 1] = line
    end
  end
  return out
end

--- 可用区域：避开 tabline（首行）、statusline（laststatus != 0）与命令行（cmdheight 行）
--- @return { top: integer, bottom: integer, left: integer, right: integer } 0 起始，bottom / right 为开区间
local function usable_area()
  local lines, columns = vim.o.lines, vim.o.columns
  local top = vim.o.showtabline ~= 0 and 1 or 0
  local bottom = lines - vim.o.cmdheight - (vim.o.laststatus ~= 0 and 1 or 0)
  if bottom <= top then
    bottom = lines - vim.o.cmdheight
  end
  return { top = top, bottom = bottom, left = 0, right = columns }
end

--- 顶部窗口是否用首行放了 winbar（顶部锚点要让出这一行；默认的底部锚点不受影响）
--- @return integer 0 或 1
local function top_inset()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local min_row
  for _, win in ipairs(wins) do
    local row = vim.api.nvim_win_get_position(win)[1]
    if min_row == nil or row < min_row then
      min_row = row
    end
  end
  if min_row == nil then
    return 0
  end
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_position(win)[1] == min_row and vim.wo[win].winbar ~= "" then
      return 1
    end
  end
  return 0
end

-- ============================================================
-- 高亮
-- ============================================================

--- 本模块高亮组名前缀
local function group_prefix()
  return (type(cfg.colors) == "table" and cfg.colors.group) or "CustomNotify"
end

--- 应用等级边框色（切换主题后由 ColorScheme 自动再调用一次）
local function apply_highlights()
  if type(cfg.colors) ~= "table" then
    return
  end
  local prefix = group_prefix()
  for _, name in ipairs(LEVEL_ORDER) do
    local color = cfg.colors.border and cfg.colors.border[name]
    if color then
      vim.api.nvim_set_hl(0, prefix .. "Border" .. name, { fg = color })
    end
  end
  if cfg.colors.normal then
    vim.api.nvim_set_hl(0, prefix .. "Normal", cfg.colors.normal)
  end
end

--- 浮动窗口的 winhighlight：把边框 / 标题 / 正文映射到本模块的高亮组
--- @param level integer
--- @return string winhighlight 字符串（无映射项时为空串）
local function winhighlight(level)
  if type(cfg.colors) ~= "table" then
    return ""
  end
  local prefix = group_prefix()
  local name = level_name(level)
  local parts = {}
  if cfg.colors.border and cfg.colors.border[name] then
    parts[#parts + 1] = "FloatBorder:" .. prefix .. "Border" .. name
    parts[#parts + 1] = "FloatTitle:" .. prefix .. "Border" .. name
  end
  if cfg.colors.normal then
    parts[#parts + 1] = "NormalFloat:" .. prefix .. "Normal"
  end
  return table.concat(parts, ",")
end

-- ============================================================
-- 浮动窗口
-- ============================================================

--- 折行并计算内容宽度（受 cfg.min_width / cfg.max_width 约束）
--- @param text string
--- @return string[] lines, integer width
local function layout_text(text)
  local area = usable_area()
  local max_width = math.max(1, math.min(cfg.max_width, area.right - cfg.margin.col * 2))
  local lines = wrap(text, max_width)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  return lines, math.max(math.min(cfg.min_width, max_width), math.min(width, max_width))
end

--- 高度超限时截断并在末行补省略号
--- @param lines string[]
--- @param limit integer
--- @return string[]
local function clamp_height(lines, limit)
  if #lines <= limit then
    return lines
  end
  local out = {}
  for i = 1, limit do
    out[i] = lines[i]
  end
  out[limit] = (out[limit]:gsub("%s+$", "")) .. "…"
  return out
end

--- 内容高度上限（同时受 cfg.max_height 与可用区域限制）
--- @return integer
local function content_height_limit()
  local area = usable_area()
  return math.max(1, math.min(cfg.max_height, area.bottom - area.top))
end

--- 新建一条通知的浮动窗口（行 / 列稍后由 layout() 统一摆放）
--- @param text string
--- @param level integer
--- @param title string|nil
--- @return table rec
local function open_float(text, level, title)
  local lines, width = layout_text(text)
  lines = clamp_height(lines, content_height_limit())

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    row = 0,
    col = 0,
    width = width,
    height = #lines,
    style = "minimal",
    border = cfg.border,
    title = title,
    title_pos = title and "center" or nil,
    focusable = false,
    zindex = cfg.zindex,
  })

  vim.wo[win].winblend = cfg.winblend
  vim.wo[win].winhighlight = winhighlight(level)

  return { win = win, buf = buf, level = level, width = width, height = #lines, kind = nil, timer = nil }
end

--- 原地更新一条通知（内容 / 等级 / 尺寸都可能变化）
--- @param rec table
--- @param text string
--- @param level integer
--- @param title string|nil
--- @return boolean 是否更新成功（窗口已失效时返回 false）
local function update_float(rec, text, level, title)
  if not (vim.api.nvim_win_is_valid(rec.win) and vim.api.nvim_buf_is_valid(rec.buf)) then
    return false
  end

  local lines, width = layout_text(text)
  lines = clamp_height(lines, content_height_limit())

  vim.bo[rec.buf].modifiable = true
  vim.api.nvim_buf_set_lines(rec.buf, 0, -1, false, lines)
  vim.bo[rec.buf].modifiable = false

  rec.level, rec.width, rec.height = level, width, #lines
  vim.api.nvim_win_set_config(rec.win, {
    width = width,
    height = #lines,
    title = title,
    title_pos = title and "center" or nil,
  })
  vim.wo[rec.win].winhighlight = winhighlight(level)
  return true
end

--- 重排所有浮动窗口：新的靠锚点，旧的向内推
local function layout()
  if #active == 0 then
    return
  end

  local area = usable_area()
  local top = cfg.position:find("^top") ~= nil
  local left = cfg.position:find("left$") ~= nil
  local cursor = top and (area.top + cfg.margin.row + top_inset()) or (area.bottom - cfg.margin.row)

  for i = #active, 1, -1 do
    local rec = active[i]
    if not vim.api.nvim_win_is_valid(rec.win) then
      table.remove(active, i)
    else
      local row = top and cursor or (cursor - rec.height)
      local col = left and cfg.margin.col or (area.right - cfg.margin.col - rec.width)
      vim.api.nvim_win_set_config(rec.win, {
        relative = "editor",
        row = math.max(area.top, row),
        col = math.max(0, col),
      })
      cursor = top and (cursor + rec.height) or (cursor - rec.height)
    end
  end
end

--- 关闭一条通知（只负责关窗，何时重排由调用方决定）
--- @param rec table
local function close(rec)
  if rec.timer then
    rec.timer:stop()
    rec.timer:close()
    rec.timer = nil
  end
  for i, item in ipairs(active) do
    if item == rec then
      table.remove(active, i)
      break
    end
  end
  if vim.api.nvim_win_is_valid(rec.win) then
    vim.api.nvim_win_close(rec.win, true)
  end
end

--- 可用高度放不下时丢弃最旧的若干条
local function trim_to_area()
  local area = usable_area()
  local available = area.bottom - area.top - cfg.margin.row * 2
  local total = 0
  for _, rec in ipairs(active) do
    total = total + rec.height
  end
  while #active > 1 and total > available do
    local oldest = active[1]
    total = total - oldest.height
    close(oldest)
  end
end

--- 统一的重排入口：先按可用高度裁剪，再摆放位置
local function relayout()
  trim_to_area()
  layout()
end

--- 按等级启动自动关闭计时（timeout <= 0 表示常驻）
--- @param rec table
local function arm_timer(rec)
  if rec.timer then
    rec.timer:stop()
    rec.timer:close()
    rec.timer = nil
  end

  local ms = type(cfg.timeout) == "table" and cfg.timeout[level_name(rec.level)] or nil
  if type(ms) ~= "number" or ms <= 0 then
    return
  end

  local timer = vim.uv.new_timer()
  rec.timer = timer
  timer:start(
    ms,
    0,
    vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      rec.timer = nil
      close(rec)
      relayout()
    end)
  )
end

-- ============================================================
-- 对外 API
-- ============================================================

--- 进度类通知的合并键：同 kind + 同 source/title 视为同一条（原地更新，不刷屏）
--- @param opts table
--- @return string|nil
local function progress_key(opts)
  if opts.kind ~= "progress" then
    return nil
  end
  return "progress:" .. tostring(opts.source or opts.title or "")
end

--- 发一条浮动通知（接管后的 vim.notify 就是本函数）
--- @param msg string|table 通知内容
--- @param level integer|nil 等级（vim.log.levels，缺省 INFO）
--- @param opts table|nil 可选：kind / source / title 等（icon、hl_group 忽略，保持简约）
--- @return table|nil 成功时返回内部记录
function M.notify(msg, level, opts)
  opts = opts or {}
  level = level or vim.log.levels.INFO

  -- 停用或没有 UI（headless / -es）时透传原生实现
  if not cfg.enabled or #vim.api.nvim_list_uis() == 0 then
    return orig_notify(msg, level, opts)
  end

  local text = to_text(msg)
  local title = type(opts.title) == "string" and opts.title or (cfg.title and level_name(level) or nil)

  if cfg.history then
    -- 保留 :messages 历史；代价是命令行区也会出现一行文本（默认关闭）
    vim.api.nvim_echo({ { text } }, true, { err = level == vim.log.levels.ERROR })
  end

  -- 渲染失败（例如 border / margin 配置写错）时不吞掉通知，退回原生实现
  local ok, rec = pcall(function()
    local key = progress_key(opts)

    -- 进度通知：命中同 key 的那条原地更新
    if key then
      for _, item in ipairs(active) do
        if item.kind == key and update_float(item, text, level, title) then
          arm_timer(item) -- 每次更新都刷新计时：进度持续时不会自己消失
          relayout()
          return item
        end
      end
    end

    local new = open_float(text, level, title)
    new.kind = key
    active[#active + 1] = new
    while #active > math.max(1, cfg.max_visible) do
      close(active[1])
    end
    arm_timer(new)
    relayout()
    return new
  end)

  if not ok then
    return orig_notify(msg, level, opts)
  end
  return rec
end

--- 关闭全部浮动通知
--- @return table M
function M.clear()
  while #active > 0 do
    close(active[#active])
  end
  return M
end

--- 启用浮动通知
--- @return table M
function M.enable()
  cfg.enabled = true
  return M
end

--- 停用浮动通知（同时关闭已显示的通知；之后透传原生实现）
--- @return table M
function M.disable()
  cfg.enabled = false
  M.clear()
  return M
end

--- 在启用 / 停用之间切换
--- @return table M
function M.toggle()
  if cfg.enabled then
    return M.disable()
  end
  return M.enable()
end

--- 还原原生 vim.notify（并关闭已显示的浮动通知）
--- @return table M
function M.restore()
  M.clear()
  vim.notify = orig_notify
  return M
end

--- 启用浮动通知（幂等：重复调用只注册一次，但会同步更新配置与配色）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  apply_highlights() -- 允许重复 setup 时立即应用新配色

  if initialized then
    return M
  end
  initialized = true

  local augroup = vim.api.nvim_create_augroup("custom_notify", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    desc = "custom.notify: 主题切换后重新应用等级配色",
    callback = apply_highlights,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "custom.notify: 终端尺寸变化后重排通知",
    callback = relayout,
  })

  -- 接管 vim.notify（原生实现保存在 orig_notify，用于停用 / 无 UI 时透传）
  vim.notify = function(msg, level, nopts)
    return M.notify(msg, level, nopts)
  end

  vim.api.nvim_create_user_command("NotifyTest", function(args)
    local name = args.args ~= "" and args.args:upper() or "INFO"
    local message = "NotifyTest: " .. name .. " 级别通知（用于检查浮动提示外观）"
    M.notify(message, vim.log.levels[name] or vim.log.levels.INFO)
  end, {
    nargs = "?",
    complete = function()
      return { "trace", "debug", "info", "warn", "error" }
    end,
    desc = "custom.notify: 发一条测试通知",
  })

  vim.api.nvim_create_user_command("NotifyClose", function()
    M.clear()
  end, { desc = "custom.notify: 关闭全部浮动通知" })

  vim.api.nvim_create_user_command("NotifyToggle", function()
    M.toggle()
    M.notify("浮动通知: " .. (cfg.enabled and "已启用" or "已停用"), vim.log.levels.INFO)
  end, { desc = "custom.notify: 启用 / 停用浮动通知" })

  return M
end

return M
