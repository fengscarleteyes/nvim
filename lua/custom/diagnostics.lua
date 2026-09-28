-- ============================================================
-- 诊断浮动窗口：屏幕右侧常驻浮窗，上半显示各级别数量，下半列出诊断条目
-- ------------------------------------------------------------
--   * 只统计当前缓冲区；有诊断才显示，诊断消失即关闭；
--   * 上半：居中显示各级别数量（如 "2 错误  1 警告"），不抢焦点；
--   * 中间：一条跟随边框样式的分隔线（border 为 none / solid / shadow 时不画）；
--   * 下半：诊断列表，j/k 移动光标即跳到对应诊断行，回车再跳一次；
--   * 切换缓冲区 / 窗口 / filetype、终端缩放、诊断变化（防抖）时自动刷新；
--   * filetype 在 disable_filetypes 内、无 UI（headless / -es）时不显示；
--   * 配色跟随主题：DiagnosticError / DiagnosticWarn / DiagnosticInfo / DiagnosticHint。
--
-- 布局：floating window，靠屏幕右侧、垂直居中；含边框整体保证落在可见区内。
--   border 用 nvim_open_win 的边框名（none / single / double / rounded / solid /
--   shadow，高亮组 FloatBorder / FloatShadow 跟随主题），或 8 元素数组
--   （顺时针、从左上角起；分隔线取数组第 2 项，即上边框字符）。
--
-- API：
--   require("custom.diagnostics").setup([opts])  合并配置并生效（幂等）
--   require("custom.diagnostics").update()       按当前缓冲区立即刷新
--   require("custom.diagnostics").hide()         立即关闭
--
-- 用户命令：
--   :DiagNext / :DiagPrev          跳到下一条 / 上一条诊断
--   :DiagCopyLine / :DiagCopyBuffer  复制当前行 / 整个缓冲区的诊断到剪贴板
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   disable_filetypes table          { "mason", "dashboard" }  这些 filetype 不显示面板
--   width             number         50       浮窗宽度（列）
--   height            number         20       浮窗高度（行）
--   border            string|table   "single" 边框，见上文「布局」
--   separator         string         "  "     各级别数量之间的分隔符
--   labels            table          { ERROR = "错误", WARN = "警告", INFO = "信息", HINT = "提示" }
--   debounce_ms       number         200      诊断变化后的刷新防抖（0 = 立即刷新）
--   map_keys          boolean        false    是否绑定默认键位
--   keys              table          { copy_line = "<leader>dc", copy_buffer = "<leader>dC" }
--
-- 示例：
--   require("custom.diagnostics").setup()
--   require("custom.diagnostics").setup({ width = 60, height = 25, border = "rounded" })
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  disable_filetypes = { "mason", "dashboard" },
  width = 50,
  height = 20,
  border = "single",
  separator = "  ",
  labels = { ERROR = "错误", WARN = "警告", INFO = "信息", HINT = "提示" },
  debounce_ms = 200,
  map_keys = false,
  keys = {
    copy_line = "<leader>dc",
    copy_buffer = "<leader>dC",
  },
}

--- 严重程度：显示顺序 + 对应的主题高亮组
local SEVERITY = {
  { sev = vim.diagnostic.severity.ERROR, name = "ERROR", hl = "DiagnosticError" },
  { sev = vim.diagnostic.severity.WARN, name = "WARN", hl = "DiagnosticWarn" },
  { sev = vim.diagnostic.severity.INFO, name = "INFO", hl = "DiagnosticInfo" },
  { sev = vim.diagnostic.severity.HINT, name = "HINT", hl = "DiagnosticHint" },
}

local cfg = vim.deepcopy(DEFAULTS)
local initialized = false
local commands_created = false
local keymaps_created = false
local float_win = nil -- 浮动窗口
local float_buf = nil -- 浮动窗口缓冲区
local float_border = nil -- 浮动窗口当前使用的边框（配置变了要重建，见 ensure_window）
local timer = nil -- 防抖定时器
local retry_used = false
local retry_later
local ns = vim.api.nvim_create_namespace("custom_diagnostics")
local list_ns = vim.api.nvim_create_namespace("custom_diagnostics_list")

--- 级别文案
--- @param sev integer|nil
--- @return string
local function severity_label(sev)
  for _, item in ipairs(SEVERITY) do
    if item.sev == sev then
      return cfg.labels[item.name] or item.name
    end
  end
  return cfg.labels.INFO or "INFO"
end

--- 面板缓冲区的 filetype
local PANEL_FT = "custom_diag"

--- nvim_open_win 内置的边框名（字符串形式）
local BORDER_NAMES = {
  none = true,
  single = true,
  double = true,
  rounded = true,
  solid = true,
  shadow = true,
}

--- 归一化 cfg.border：内置名直接用（高亮跟随主题）、表原样透传、
--- false / "" 视为 none、非法值回退 single
--- @return string|table
local function resolve_border()
  local border = cfg.border
  if type(border) == "table" then
    return border
  end
  if border == false or border == nil or border == "" then
    return "none"
  end
  if type(border) == "string" and BORDER_NAMES[border] then
    return border
  end
  return "single"
end

--- 内置边框名 -> 横线字符（此处没有的边框名取到 nil，即不画分隔线）
local BORDER_HCHAR = {
  single = "─",
  double = "═",
  rounded = "─",
}

--- 分隔线字符：跟随边框样式（自定义 8 元素数组取第 2 项，即上边框字符）
--- @return string|nil border 为 none / solid / shadow 等无横线边框时为 nil
local function divider_char()
  local border = resolve_border()
  local ch
  if type(border) == "table" then
    ch = border[2]
    if type(ch) == "table" then
      ch = ch[1] -- nvim_open_win 允许元素写成 { 字符, 高亮组 }
    end
  else
    ch = BORDER_HCHAR[border]
  end
  if type(ch) ~= "string" or ch == "" or ch == " " then
    return nil
  end
  return ch
end

--- 表头行数：统计行 +（可选的）分隔线
--- @return integer
local function header_rows()
  return divider_char() and 2 or 1
end

--- 该缓冲区是否需要显示面板
--- @param bufnr integer
--- @return boolean
local function should_show(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local ft = vim.bo[bufnr].filetype
  if ft == PANEL_FT then
    return false
  end
  return not vim.tbl_contains(cfg.disable_filetypes or {}, ft)
end

--- 关闭浮动窗口
function M.hide()
  local win, buf = float_win, float_buf
  float_win, float_buf, float_border = nil, nil, nil

  if win and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_close, win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

--- 当前缓冲区的各级别数量 -> 文本片段
--- @param bufnr integer
--- @return { text: string, hl: string }[]
local function status_parts(bufnr)
  local counts = vim.diagnostic.count(bufnr)
  local parts = {}
  for _, item in ipairs(SEVERITY) do
    local count = counts[item.sev] or 0
    if count > 0 then
      parts[#parts + 1] = { text = ("%d %s"):format(count, severity_label(item.sev)), hl = item.hl }
    end
  end
  return parts
end

--- 把片段拼成一行
--- @param parts { text: string, hl: string }[]
--- @param budget integer
--- @return string text, { start: integer, finish: integer, hl: string }[] spans
local function build_line(parts, budget)
  local text, spans, used = "", {}, 0
  for i, part in ipairs(parts) do
    local sep = i > 1 and cfg.separator or ""
    local piece = sep .. part.text
    if used + vim.fn.strdisplaywidth(piece) > budget then
      if used + 1 <= budget then
        text = text .. "…"
      end
      break
    end
    local start = #text + #sep
    text = text .. piece
    used = used + vim.fn.strdisplaywidth(piece)
    spans[#spans + 1] = { start = start, finish = #text, hl = part.hl }
  end
  return text, spans
end

--- 创建浮动窗口
--- @return integer|nil win, integer|nil buf
local function ensure_window()
  local border = resolve_border()
  local reusable = float_win
    and vim.api.nvim_win_is_valid(float_win)
    and float_buf
    and vim.api.nvim_buf_is_valid(float_buf)
    and float_border == border -- 边框配置变了要重建（分隔线跟着边框走）

  if reusable then
    return float_win, float_buf
  end

  M.hide()

  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return nil, nil
  end

  local adj = border ~= "none" and 1 or 0 -- 边框画在窗口外侧，每边多占 1 格
  -- 命令行绘制在浮窗之上、会盖住底边框，可用高度先扣掉 cmdheight
  local avail_h = math.max(1, ui.height - (vim.o.cmdheight or 0))
  local avail_w = ui.width

  -- 放不下「表头 + 至少一条列表（+ 上下边框）」就不显示
  if avail_w < adj * 2 + 1 or avail_h < adj * 2 + header_rows() + 1 then
    return nil, nil
  end

  local width = math.min(cfg.width, avail_w - adj * 2 - 1)
  local height = math.min(math.max(cfg.height, header_rows() + 1), avail_h - adj * 2)

  -- 靠右、垂直居中，再把「含边框的整体」夹回可见区内
  local row = math.floor((avail_h - height) / 2) - 1
  row = math.max(adj, math.min(row, avail_h - height - adj))
  local col = math.max(adj, avail_w - width - 1)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local ok, win = pcall(vim.api.nvim_open_win, buf, false, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = border,
    style = "minimal",
    noautocmd = true,
  })

  if not ok or not vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    retry_later()
    return nil, nil
  end

  float_win, float_buf, float_border = win, buf, border
  vim.bo[buf].filetype = PANEL_FT

  -- 窗口配置
  vim.wo[win].winbar = ""
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].wrap = false
  vim.wo[win].list = false
  vim.wo[win].spell = false
  vim.wo[win].cursorline = false

  return win, buf
end

--- 刷新浮动窗口
local function update()
  -- 无 UI（headless / -es）时不创建窗口
  if #vim.api.nvim_list_uis() == 0 then
    M.hide()
    return
  end

  -- 当前窗口是浮动窗（fzf / :Mason 等）或面板自身时保持原样
  local cur_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(cur_win).relative ~= "" then
    return
  end
  if float_win and vim.api.nvim_win_is_valid(float_win) and cur_win == float_win then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local show = should_show(bufnr)
  local parts = show and status_parts(bufnr) or {}
  local diags = show and vim.diagnostic.get(bufnr) or {}

  if #parts == 0 then
    M.hide()
    return
  end

  local win, buf = ensure_window()
  if not win or not buf then
    return
  end

  -- 内容分三段：统计行 / 分隔线（可选）/ 诊断列表
  local width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)
  local header = header_rows()
  local list_height = win_height - header

  local lines = {}
  for i = 1, win_height do
    lines[i] = ""
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(buf, list_ns, 0, -1)

  -- 统计行：居中的各级别数量
  local status_text, spans = build_line(parts, math.max(1, width - 2))
  local pad = math.max(1, math.floor((width - vim.fn.strdisplaywidth(status_text)) / 2))
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { string.rep(" ", pad) .. status_text })
  for _, span in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(buf, ns, 0, pad + span.start, {
      end_col = pad + span.finish,
      hl_group = span.hl,
    })
  end

  -- 分隔线：铺满内容宽度，与窗口边框同色
  local dch = divider_char()
  if dch then
    local divider = string.rep(dch, width)
    vim.api.nvim_buf_set_lines(buf, 1, 2, false, { divider })
    vim.api.nvim_buf_set_extmark(buf, ns, 1, 0, { end_col = #divider, hl_group = "FloatBorder" })
  end

  -- 诊断列表：每条一行 "级别:行:列 消息"
  local max_lines = math.min(#diags, list_height)
  for i = 1, max_lines do
    local d = diags[i]
    local severity, hl = "Unknown", "DiagnosticError"
    for _, item in ipairs(SEVERITY) do
      if item.sev == d.severity then
        severity, hl = item.name, item.hl
        break
      end
    end

    local msg = (d.message or ""):gsub("%s+", " ")
    if #msg > width - 15 then
      msg = msg:sub(1, width - 18) .. "..."
    end

    local row0 = header + i - 1
    local text = ("%s:%d:%d %s"):format(severity, d.lnum + 1, d.col + 1, msg)
    vim.api.nvim_buf_set_lines(buf, row0, row0 + 1, false, { text })
    vim.api.nvim_buf_set_extmark(buf, list_ns, row0, 0, { end_col = #severity, hl_group = hl })
  end

  -- 面板状态（1-based）：列表起始行 / 行数 / 当前条目 / 来源缓冲区
  vim.w[win].diag_list_start = header + 1
  vim.w[win].diag_list_height = max_lines
  vim.w[win].diag_current_idx = 1
  vim.w[win].diag_source_bufnr = bufnr
  vim.w[win].diag_list = diags

  vim.api.nvim_win_set_cursor(win, { header + 1, 0 })
end

--- 立即刷新窗口
M.update = update

--- 事件驱动的刷新入口
local function refresh()
  retry_used = false
  update()
end

--- 创建窗口失败时重试
retry_later = function()
  if retry_used then
    return
  end
  retry_used = true
  vim.schedule(update)
end

--- 防抖刷新
local function schedule_update()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end

  local ms = tonumber(cfg.debounce_ms) or 0
  if ms <= 0 then
    update()
    return
  end

  local handle = vim.uv.new_timer()
  if not handle then
    update()
    return
  end

  local t = handle
  timer = t
  t:start(
    ms,
    0,
    vim.schedule_wrap(function()
      t:stop()
      t:close()
      timer = nil
      refresh()
    end)
  )
end

--- 跳转到指定诊断（1-based）：聚焦来源缓冲区所在窗口并把光标移到诊断处
--- @param idx integer
local function jump_to_diag(idx)
  if not float_win or not vim.api.nvim_win_is_valid(float_win) then
    return
  end

  local bufnr = tonumber(vim.api.nvim_win_get_var(float_win, "diag_source_bufnr"))
  local diags = vim.api.nvim_win_get_var(float_win, "diag_list")
  local diag_idx = tonumber(idx)

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if not diags or not diag_idx or diag_idx < 1 or diag_idx > #diags then
    return
  end

  local d = diags[diag_idx]

  -- 聚焦来源缓冲区所在窗口；没有窗口显示它时才用 :buffer 打开
  local target_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      target_win = win
      break
    end
  end
  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    vim.cmd("buffer " .. bufnr)
    target_win = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_win_set_cursor(target_win, { d.lnum + 1, d.col })
  vim.cmd("normal! zvzz") -- 打开折叠并居中
end

--- 处理浮动窗口内的光标移动：光标落在列表区域内就跳到对应诊断
local function handle_cursor_move()
  if not float_win or not vim.api.nvim_win_is_valid(float_win) then
    return
  end

  local start = vim.api.nvim_win_get_var(float_win, "diag_list_start") -- 列表首行（1-based）
  local height = vim.api.nvim_win_get_var(float_win, "diag_list_height")
  local current = vim.api.nvim_win_get_var(float_win, "diag_current_idx")
  local diags = vim.api.nvim_win_get_var(float_win, "diag_list")

  if not start or not height or not diags or #diags == 0 then
    return
  end

  local row = vim.api.nvim_win_get_cursor(float_win)[1]
  if row < start or row >= start + height then
    return
  end

  local idx = row - start + 1
  if idx ~= current then
    vim.api.nvim_win_set_var(float_win, "diag_current_idx", idx)
    vim.schedule(function()
      jump_to_diag(idx)
    end)
  end
end

-- ============================================================
-- 复制到剪贴板
-- ============================================================

--- 一条诊断的文本
--- @param d table
--- @return string
local function diag_line(d)
  local bufnr = d.bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local file = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"
  local msg = (d.message or ""):gsub("%s+", " ")
  return ("%s:%d:%d [%s] %s"):format(file, d.lnum + 1, d.col + 1, severity_label(d.severity), msg)
end

--- 复制若干条诊断到剪贴板
--- @param list table[]
local function copy(list)
  if #list == 0 then
    vim.notify("没有可复制的诊断", vim.log.levels.INFO)
    return
  end

  local lines = {}
  for _, d in ipairs(list) do
    lines[#lines + 1] = diag_line(d)
  end
  local text = table.concat(lines, "\n")

  local reg = vim.fn.has("clipboard") == 1 and "+" or '"'
  if not pcall(vim.fn.setreg, reg, text) and reg ~= '"' then
    vim.fn.setreg('"', text)
  end

  vim.notify(("已复制 %d 条诊断到剪贴板"):format(#lines), vim.log.levels.INFO)
end

--- 光标所在行的诊断
--- @param bufnr integer
--- @return table[]
local function line_diagnostics(bufnr)
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local ok, list = pcall(vim.diagnostic.get, bufnr, { lnum = lnum })
  if ok and list then
    return list
  end

  local out = {}
  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    if d.lnum == lnum then
      out[#out + 1] = d
    end
  end
  return out
end

-- ============================================================
-- 命令与键位
-- ============================================================

local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true

  vim.api.nvim_create_user_command("DiagNext", function()
    vim.diagnostic.jump({ count = 1, float = false })
  end, { desc = "Diagnostics: 跳到下一条诊断" })

  vim.api.nvim_create_user_command("DiagPrev", function()
    vim.diagnostic.jump({ count = -1, float = false })
  end, { desc = "Diagnostics: 跳到上一条诊断" })

  vim.api.nvim_create_user_command("DiagCopyLine", function()
    copy(line_diagnostics(vim.api.nvim_get_current_buf()))
  end, { desc = "Diagnostics: 复制当前行诊断" })

  vim.api.nvim_create_user_command("DiagCopyBuffer", function()
    copy(vim.diagnostic.get(vim.api.nvim_get_current_buf()))
  end, { desc = "Diagnostics: 复制缓冲区全部诊断" })
end

local function ensure_keymaps()
  if keymaps_created or not cfg.map_keys then
    return
  end
  keymaps_created = true

  local keys = cfg.keys or {}
  local function map(lhs, cmd, desc)
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, "<Cmd>" .. cmd .. "<CR>", { silent = true, desc = desc })
    end
  end
  map(keys.copy_line, "DiagCopyLine", "Diagnostics: 复制当前行诊断")
  map(keys.copy_buffer, "DiagCopyBuffer", "Diagnostics: 复制缓冲区全部诊断")
end

-- ============================================================
-- 入口
-- ============================================================

--- @param opts table|nil
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})

  if opts and opts.disable_filetypes ~= nil then
    cfg.disable_filetypes = opts.disable_filetypes
  end

  if initialized then
    ensure_keymaps()
    update()
    return M
  end
  initialized = true

  local augroup = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

  -- 诊断变化
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    desc = "custom.diagnostics: 诊断变化后刷新浮动窗口",
    callback = schedule_update,
  })

  -- 切换缓冲区 / 窗口 / 文件类型
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "FileType" }, {
    group = augroup,
    desc = "custom.diagnostics: 切换缓冲区 / 窗口 / 文件类型后刷新",
    callback = refresh,
  })

  -- 终端尺寸变化
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "custom.diagnostics: 终端尺寸变化后重新定位",
    callback = refresh,
  })

  -- 浮动窗口内的光标移动检测
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    desc = "custom.diagnostics: 浮动窗口内光标移动",
    callback = function(args)
      if float_win and vim.api.nvim_win_is_valid(float_win) then
        local cur_win = vim.api.nvim_get_current_win()
        if cur_win == float_win then
          handle_cursor_move()
        end
      end
    end,
  })

  -- 回车键跳转
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    desc = "custom.diagnostics: 设置回车键跳转",
    callback = function(args)
      if args.buf == float_buf and float_buf then
        vim.keymap.set("n", "<CR>", function()
          local idx = vim.api.nvim_win_get_var(float_win, "diag_current_idx")
          if idx then
            jump_to_diag(idx)
          end
        end, { buffer = float_buf, nowait = true })
      end
    end,
  })

  ensure_commands()
  ensure_keymaps()
  refresh()

  return M
end

return M
