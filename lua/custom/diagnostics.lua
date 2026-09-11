-- ============================================
-- 诊断高亮（背景色与前景色互换）
-- ============================================

-- 严重程度 -> 名称 / 图标 / 文案 / 配色（单一数据源，高亮与通知共用）
-- name 同时用于拼接内置高亮组名：DiagnosticUnderline .. name
-- 注意：内置该高亮组作用于「诊断的起止列区间」，并非整行（整行高亮见文件末尾）
local severity_config = {
  [vim.diagnostic.severity.ERROR] = { name = "Error", icon = "✘", label = "错误", bg = "#FF6B6B", fg = "#FFFFFF" },
  [vim.diagnostic.severity.WARN] = { name = "Warn", icon = "▲", label = "警告", bg = "#FFD93D", fg = "#000000" },
  [vim.diagnostic.severity.INFO] = { name = "Info", icon = "»", label = "信息", bg = "#6BCB77", fg = "#FFFFFF" },
  [vim.diagnostic.severity.HINT] = { name = "Hint", icon = "⚑", label = "提示", bg = "#4D96FF", fg = "#FFFFFF" },
}

-- 固定展示顺序：错误 -> 警告 -> 信息 -> 提示
-- （不要用 pairs 遍历 severity_config，否则顺序不确定）
local severity_order = {
  vim.diagnostic.severity.ERROR,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.HINT,
}

-- 本文件所有自动命令共用一个 augroup
-- clear = true 保证重复 source 本文件时不会累积重复的自动命令
local augroup = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

--- 应用诊断高亮：各严重程度一套「背景色 + 前景色」
local function apply_highlights()
  for _, severity in ipairs(severity_order) do
    local s = severity_config[severity]
    -- 内置 underline 处理器会给诊断区间套用 DiagnosticUnderline<级别>
    vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. s.name, { bg = s.bg, fg = s.fg })
  end
end

apply_highlights()

-- 切换配色方案会重置全部高亮组，这里在 ColorScheme 之后重新覆盖一次
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = apply_highlights,
})

-- ============================================
-- 可选：诊断所在整行背景高亮（默认关闭）
-- ============================================
-- 取消注释下面一段即可：通过 signs.linehl 给「放有诊断符号的整行」上背景色
-- （需保持 signs 开启，vim.diagnostic.config 默认即为 true）。
-- 注意：这些整行高亮组在切换配色方案后会被重置，
--       如需长期生效，请把 nvim_set_hl 那行一并挪进上面的 apply_highlights()。
-- local linehl = {}
-- for _, severity in ipairs(severity_order) do
--   local s = severity_config[severity]
--   vim.api.nvim_set_hl(0, "DiagnosticLine" .. s.name, { bg = s.bg })
--   linehl[severity] = "DiagnosticLine" .. s.name
-- end
-- vim.diagnostic.config({ signs = { linehl = linehl } })

-- ============================================
-- 诊断提醒（防抖 + 分类统计）
-- ============================================

-- 防抖时长（毫秒）
local DEBOUNCE_MS = 500

-- 待提醒的缓冲区集合
-- 所有事件共用一个定时器做防抖，但同一防抖窗口内触发过的缓冲区都会记录下来
-- 并逐个提醒，避免后触发的缓冲区把先触发的顶掉（丢失提醒）
local pending_bufs = {}

-- 用于防抖的 libuv 定时器
local diag_timer = vim.uv.new_timer()

--- 统计指定缓冲区的诊断，并按严重程度分类提醒
--- @param buf integer 缓冲区编号
local function notify_diagnostics(buf)
  -- 缓冲区可能已被删除
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- 该缓冲区的所有诊断项
  local diagnostics = vim.diagnostic.get(buf)

  -- 没有诊断问题
  if #diagnostics == 0 then
    vim.notify("✅ 无诊断错误", vim.log.levels.INFO)
    return
  end

  -- 按严重程度分类计数（severity 缺失时按 INFO 处理）
  local counts = {}
  for _, d in ipairs(diagnostics) do
    local severity = d.severity or vim.diagnostic.severity.INFO
    counts[severity] = (counts[severity] or 0) + 1
  end

  -- 只拼接数量大于 0 的分类，例如："✘ 1 错误  ▲ 2 警告"
  local parts = {}
  for _, severity in ipairs(severity_order) do
    local count = counts[severity]
    if count then
      local s = severity_config[severity]
      parts[#parts + 1] = string.format("%s %d %s", s.icon, count, s.label)
    end
  end

  -- 日志级别：有错误时用 ERROR，否则用 WARN
  local level = counts[vim.diagnostic.severity.ERROR] and vim.log.levels.ERROR or vim.log.levels.WARN
  vim.notify("诊断: " .. table.concat(parts, "  "), level)
end

-- 监听 DiagnosticChanged 事件
-- 当 LSP 或 linter 产生、更新、清除诊断信息时触发
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = augroup,
  callback = function(args)
    -- args.buf 是触发事件的缓冲区编号，稍后据此获取该缓冲区的诊断
    pending_bufs[args.buf] = true

    -- 防抖逻辑：每次触发时先停止上一次的计时器
    -- 这样短时间内多次触发只会执行最后一次
    diag_timer:stop()

    -- 重新启动计时器，DEBOUNCE_MS 后执行回调
    -- 第二个参数 0 表示只执行一次（非重复定时器）
    -- vim.schedule_wrap 将回调调度到 Neovim 主线程
    -- 因为 uv.timer 的回调默认在 libuv 线程中运行
    -- 直接调用 vim.notify 等 Neovim API 会报错
    diag_timer:start(
      DEBOUNCE_MS,
      0,
      vim.schedule_wrap(function()
        -- 取走当前批次并清空集合，避免处理期间的新事件被丢弃
        local bufs = pending_bufs
        pending_bufs = {}
        for buf in pairs(bufs) do
          notify_diagnostics(buf)
        end
      end)
    )
  end,
})
