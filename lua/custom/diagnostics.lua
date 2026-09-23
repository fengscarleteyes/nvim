-- ============================================================
-- 诊断统计窗口（固定的分割窗口，仿 VS Code 的底部面板）
-- ------------------------------------------------------------
-- 行为：
--   * 当前缓冲区有诊断时，自动在底部（默认）分出一个固定的分割窗口——
--     真实窗口而不是浮动窗（等价于 :split / :vsplit 出来的窗口），只显示各级别的「数量」，
--     如 "2 错误  1 警告"（无图标；数量为 0 的级别不显示）；
--   * 诊断全部消失时窗口自动关闭；切换缓冲区 / 窗口（WinEnter）/ 文件类型 / 终端尺寸变化时自动刷新；
--   * 统计对象是「当前窗口的缓冲区」；当前窗口若是浮动窗（fzf-lua / :Mason / 浮动终端 / :LspInfo 等）
--     或面板自身，则保持面板现状不动（这些缓冲区没有诊断，否则会把面板误关掉）；
--   * 面板创建遇到瞬时失败（例如 E242: Can't split a window while closing another —— 窗口正在
--     关闭时正好触发刷新）会在下一轮事件循环自动重试一次；
--   * 面板窗口不抢焦点（enter = false）、无行号 / 无 winbar / 固定尺寸（winfixheight）；
--   * 配色跟随主题（DiagnosticError / DiagnosticWarn / DiagnosticInfo / DiagnosticHint）；
--   * 无 UI（headless / -es）时不创建窗口，不影响脚本与测试。
--
-- 布局（split）：
--   split = "bottom"（默认，等价 :split：占底部若干行）
--   split = "right"（等价 :vsplit：占右侧若干列）
--   面板是真实窗口、会占用布局空间（这正是"固定窗体"的语义）；面板尺寸由配置决定，
--   手动 :resize 会在下次刷新时被拉回配置值。
--
-- API：
--   require("custom.diagnostics").setup([opts])   合并配置并接管（幂等）
--   require("custom.diagnostics").update()        立即按当前缓冲区刷新窗口
--   require("custom.diagnostics").hide()          立即关闭窗口
--
-- 用户命令（如 Neovim 已有对应功能则内部直接复用默认实现）：
--   :DiagNext        跳到下一条诊断（vim.diagnostic.jump；Neovim 默认 ]d 同功能）
--   :DiagPrev        跳到上一条诊断（vim.diagnostic.jump；Neovim 默认 [d 同功能）
--   :DiagCopyLine    复制光标所在行的诊断到剪贴板
--   :DiagCopyBuffer  复制当前缓冲区全部诊断到剪贴板
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   disable_filetypes table   { "mason", "dashboard" }  这些 filetype 不显示面板
--   split       string    "bottom"  分割方向：bottom（:split 底部）| right（:vsplit 右侧）
--   height      number    1         split = "bottom" 时的面板高度（行）
--   width       number    30        split = "right" 时的面板宽度（列）
--   align       string    "center"  文本对齐：center | left | right（左右各留 1 格内边距）
--   separator   string    "  "            各级别之间的分隔符
--   labels      table     { ERROR = "错误", WARN = "警告", INFO = "信息", HINT = "提示" }
--   debounce_ms number    200             诊断变化后的刷新防抖（0 = 立即刷新）
--   map_keys    boolean   false           是否绑定默认键位（默认不生效，见 keys）
--   keys = {                              lhs 设 false / "" 即不绑该键
--     copy_line   = "<leader>dc"          复制当前行诊断
--     copy_buffer = "<leader>dC"          复制缓冲区全部诊断
--   }
--
-- 示例：
--   require("custom.diagnostics").setup()                -- 全默认（底部 1 行、不绑键位）
--   require("custom.diagnostics").setup({                -- 右侧 30 列（:vsplit 风格）
--     split = "right",
--     width = 30,
--     align = "left",
--   })
--   require("custom.diagnostics").setup({                -- 底部 5 行 + 打开默认键位
--     height = 5,
--     map_keys = true,
--   })
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  disable_filetypes = { "mason", "dashboard" },
  split = "bottom", -- bottom（:split 底部）| right（:vsplit 右侧）
  height = 1, -- split = "bottom" 时的面板高度（行）
  width = 30, -- split = "right" 时的面板宽度（列）
  align = "center", -- center | left | right
  separator = "  ",
  labels = { ERROR = "错误", WARN = "警告", INFO = "信息", HINT = "提示" },
  debounce_ms = 200,
  map_keys = false,
  keys = {
    copy_line = "<leader>dc",
    copy_buffer = "<leader>dC",
  },
}

--- 严重程度：显示顺序（顺序即窗口内从左到右）+ 对应的主题高亮组
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
local status_win = nil -- 统计窗口（无效时重建）
local status_buf = nil -- 统计窗口的 scratch 缓冲区
local timer = nil -- 防抖定时器
local retry_used = false -- 本轮事件周期里是否已经重试过创建面板
local retry_later -- 创建失败时的重试函数（定义在 update 之后）
local ns = vim.api.nvim_create_namespace("custom_diagnostics")

--- 级别文案（配置里的中文标签，未知级别退回级别名）
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

--- 面板缓冲区的 filetype：winbar 等模块据此排除面板（见 custom/winbar.lua 的 hide_filetypes）
local PANEL_FT = "custom_diag"

--- 该缓冲区是否需要显示面板（disable_filetypes 命中则不显示，面板自身也不显示）
--- @param bufnr integer
--- @return boolean
local function should_show(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local ft = vim.bo[bufnr].filetype
  if ft == PANEL_FT then -- 面板自身不参与统计
    return false
  end
  return not vim.tbl_contains(cfg.disable_filetypes or {}, ft)
end

--- 关闭面板（面板是真实窗口；若它是最后一个窗口则不能关，会被保留）
--- 只关"自己登记的窗口 / 显示面板缓冲区的窗口"：创建过程中的面板尚未登记，不会被误关
function M.hide()
  local win, sbuf = status_win, status_buf
  status_win, status_buf = nil, nil

  local targets = {}
  if win and vim.api.nvim_win_is_valid(win) then
    targets[#targets + 1] = win
  end
  if sbuf and vim.api.nvim_buf_is_valid(sbuf) then
    for _, w in ipairs(vim.fn.win_findbuf(sbuf)) do
      targets[#targets + 1] = w
    end
  end

  for _, w in ipairs(targets) do
    if vim.api.nvim_win_is_valid(w) and #vim.api.nvim_list_wins() > 1 then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
end

--- 当前缓冲区的各级别数量 -> 文本片段（没有诊断时返回空列表，数量为 0 的级别不显示）
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

--- 把片段拼成一行（按显示宽度判断是否放得下，放不下时补 "…"）
--- @param parts { text: string, hl: string }[]
--- @param budget integer 文本可用的显示宽度
--- @return string text, { start: integer, finish: integer, hl: string }[] spans（字节列，供 extmark 使用）
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
    local start = #text + #sep -- 高亮区间只覆盖文本本身，不含分隔符
    text = text .. piece
    used = used + vim.fn.strdisplaywidth(piece)
    spans[#spans + 1] = { start = start, finish = #text, hl = part.hl }
  end
  return text, spans
end

--- 取得面板窗口与缓冲区（真实分割窗口；被外部关闭时重建）
--- bufhidden = wipe：窗口关闭后缓冲区一起销毁
--- @return integer|nil win, integer|nil buf 无法创建时返回 nil（例如窗口太小）
local function ensure_window()
  if status_win and vim.api.nvim_win_is_valid(status_win) and status_buf and vim.api.nvim_buf_is_valid(status_buf) then
    return status_win, status_buf
  end

  M.hide()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  -- 真实分割窗口（等价 :split / :vsplit）：
  --   enter = false    不抢焦点
  --   noautocmd = true 创建期间不触发 WinNew / BufWinEnter / WinEnter —— 否则会重入本模块的
  --                    刷新回调，而那时 status_win 尚未登记，容易把正在创建的面板关掉
  local ok, win = pcall(vim.api.nvim_open_win, buf, false, {
    split = cfg.split == "right" and "right" or "below",
    win = 0,
    noautocmd = true,
  })
  if not ok or not vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    -- 创建可能瞬时失败，例如 E242: Can't split a window while closing another
    --（窗口正在关闭时正好触发刷新就会撞上），安排下一轮事件循环重试一次
    retry_later()
    return nil, nil
  end

  -- 先登记状态、再设 filetype：FileType 是同步事件，会重入 update() 并调用 ensure_window()，
  -- 状态已就绪时重入会走"复用现有面板"分支，不会误判 / 误关
  status_win, status_buf = win, buf
  vim.bo[buf].filetype = PANEL_FT

  -- 面板窗口属性：固定尺寸、无行号、无 winbar
  -- （custom.winbar 在 BufWinEnter / WinNew 时会给非浮动窗加 winbar，这里清掉；
  --   缓冲区用专用 filetype，winbar 的 NO_WINBAR_FILETYPES 也会排除它，双保险）
  vim.wo[win].winbar = ""
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].wrap = false
  vim.wo[win].list = false
  vim.wo[win].spell = false
  vim.wo[win].cursorline = false
  vim.wo[win].winfixheight = cfg.split ~= "right"
  vim.wo[win].winfixwidth = cfg.split == "right"

  status_win, status_buf = win, buf
  return win, buf
end

--- 刷新面板：没有诊断（或该 filetype 不显示）时关闭，否则创建 / 更新内容与尺寸
local function update()
  -- 无 UI（headless / -es）时不创建窗口
  if #vim.api.nvim_list_uis() == 0 then
    M.hide()
    return
  end

  -- 当前窗口是"非统计对象"时保持原样，不改变面板状态：
  --   * 浮动窗（fzf-lua / :Mason / 浮动终端 / :LspInfo 等）：它的缓冲区没有诊断，
  --     若照常判断会把面板误关掉（此时代码缓冲区的诊断其实还在）；
  --   * 面板自身：面板缓冲区同样没有诊断，会把自己关掉。
  local cur_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(cur_win).relative ~= "" then
    return
  end
  if status_win and vim.api.nvim_win_is_valid(status_win) and cur_win == status_win then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local parts = should_show(bufnr) and status_parts(bufnr) or {}
  if #parts == 0 then
    M.hide()
    return
  end

  local win, sbuf = ensure_window()
  if not win or not sbuf then
    return
  end

  -- 面板尺寸（由配置决定；手动 :resize 会在下次刷新时被拉回配置值）
  if cfg.split == "right" then
    pcall(vim.api.nvim_win_set_width, win, math.max(10, cfg.width))
  else
    pcall(vim.api.nvim_win_set_height, win, math.max(1, cfg.height))
  end

  -- 文本：按面板实际宽度截断，再按 align 对齐（左右各留 1 格内边距）
  local width = vim.api.nvim_win_get_width(win)
  local text, spans = build_line(parts, math.max(1, width - 2))
  local content = vim.fn.strdisplaywidth(text)
  local pad
  if cfg.align == "left" then
    pad = 1
  elseif cfg.align == "right" then
    pad = math.max(1, width - content - 1)
  else
    pad = math.max(1, math.floor((width - content) / 2))
  end

  -- 内容 + 每段的主题色（extmark）
  vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, { string.rep(" ", pad) .. text })
  vim.api.nvim_buf_clear_namespace(sbuf, ns, 0, -1)
  for _, span in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(sbuf, ns, 0, pad + span.start, {
      end_col = pad + span.finish,
      hl_group = span.hl,
    })
  end
end

--- 立即刷新窗口（对外 API）
M.update = update

--- 事件驱动的刷新入口：重置重试标记（新的窗口 / 缓冲区事件允许再重试一次）后刷新
local function refresh()
  retry_used = false
  update()
end

--- 创建面板失败时，在下一轮事件循环重试一次（每个事件周期最多一次，避免死循环）
retry_later = function()
  if retry_used then
    return
  end
  retry_used = true
  vim.schedule(update)
end

--- 防抖刷新：诊断变化后延迟刷新（debounce_ms = 0 表示立即刷新）
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

  -- vim.uv.new_timer() 的返回类型是 uv_timer_t|nil（极端情况下创建失败）：失败就直接刷新
  local handle = vim.uv.new_timer()
  if not handle then
    update()
    return
  end
  --- @type uv.uv_timer_t
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

-- ============================================================
-- 复制到剪贴板
-- ============================================================

--- 一条诊断的文本：文件:行:列 [级别] 消息（消息里的换行 / 连续空白压成单空格）
--- @param d table vim.Diagnostic
--- @return string
local function diag_line(d)
  local bufnr = d.bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local file = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"
  local msg = (d.message or ""):gsub("%s+", " ")
  return ("%s:%d:%d [%s] %s"):format(file, d.lnum + 1, d.col + 1, severity_label(d.severity), msg)
end

--- 复制若干条诊断到剪贴板（无剪贴板时退回无名寄存器），并给出简短提示
--- @param list table[] vim.Diagnostic 列表
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

--- 光标所在行的诊断（Neovim 的 get() 支持按行过滤，不支持时退回自行遍历）
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

--- 注册用户命令（幂等）
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

--- 绑定默认键位（默认关：需 setup({ map_keys = true })；幂等）
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

--- 启用诊断统计窗口（幂等：重复调用只注册一次，但会同步更新配置）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  local prev_split = cfg.split
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})

  -- 列表型配置按「整体替换」处理：tbl_deep_extend 是按下标深合并的，
  -- 传 { "oil" } 会得到 { "oil", "dashboard" }（残留默认项），不符合预期
  if opts and opts.disable_filetypes ~= nil then
    cfg.disable_filetypes = opts.disable_filetypes
  end

  -- 分割方向变了：关掉现有面板，下一次刷新按新方向重建
  if prev_split ~= cfg.split then
    M.hide()
  end

  if initialized then
    ensure_keymaps()
    update()
    return M
  end
  initialized = true

  local augroup = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

  -- 诊断变化：防抖后刷新（LSP 一次推送大量诊断时避免反复刷新）
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    desc = "custom.diagnostics: 诊断变化后刷新统计窗口",
    callback = schedule_update,
  })

  -- 切换缓冲区 / 窗口 / 文件类型（disable_filetypes 依赖 FileType）：立即刷新
  -- WinEnter 是必需的：从浮动窗（fzf-lua / :Mason / 浮动终端等）返回代码窗口时只触发
  -- WinEnter、不触发 BufEnter，缺了它面板被上面那些场景隐藏后不会自动恢复
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "FileType" }, {
    group = augroup,
    desc = "custom.diagnostics: 切换缓冲区 / 窗口 / 文件类型后刷新",
    callback = refresh,
  })

  -- 终端尺寸变化：重新定位
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "custom.diagnostics: 终端尺寸变化后重新定位",
    callback = refresh,
  })

  ensure_commands()
  ensure_keymaps()
  refresh()

  return M
end

return M
