-- ============================================
-- 诊断行高亮配置（背景色与前景色互换）
-- ============================================

-- 错误级别：红色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticLineNrError", { bg = "#FF6B6B", fg = "#FFFFFF", bold = true })
-- 警告级别：黄色背景 + 黑色文字
vim.api.nvim_set_hl(0, "DiagnosticLineNrWarn", { bg = "#FFD93D", fg = "#000000", bold = true })
-- 信息级别：绿色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticLineNrInfo", { bg = "#6BCB77", fg = "#FFFFFF", bold = true })
-- 提示级别：蓝色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticLineNrHint", { bg = "#4D96FF", fg = "#FFFFFF", bold = true })

-- 将 Neovim 内置的诊断行号高亮链接到自定义高亮
vim.api.nvim_set_hl(0, "DiagnosticLineNr", { link = "DiagnosticLineNrError" })

-- ============================================
-- 诊断行整行背景高亮（背景色与前景色互换）
-- ============================================

-- 错误级别：红色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
  bg = "#FF6B6B",
  fg = "#FFFFFF",
})
-- 警告级别：黄色背景 + 黑色文字
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
  bg = "#FFD93D",
  fg = "#000000",
})
-- 信息级别：绿色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
  bg = "#6BCB77",
  fg = "#FFFFFF",
})
-- 提示级别：蓝色背景 + 白色文字
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
  bg = "#4D96FF",
  fg = "#FFFFFF",
})

-- ============================================
-- 诊断提醒 + 防抖 + 分类统计
-- ============================================

-- 创建一个 libuv 定时器，用于防抖
-- 所有 DiagnosticChanged 事件共用这一个定时器实例
local diag_timer = vim.uv.new_timer()

-- 监听 DiagnosticChanged 事件
-- 当 LSP 或 linter 产生、更新、清除诊断信息时触发
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    -- args.buf 是触发事件的缓冲区编号
    -- 用于获取该缓冲区当前的所有诊断项
    local buf = args.buf

    -- 防抖逻辑：每次触发时先停止上一次的计时器
    -- 这样短时间内多次触发只会执行最后一次
    diag_timer:stop()

    -- 重新启动计时器，500ms 后执行回调
    -- 第二个参数 0 表示只执行一次（非重复定时器）
    -- vim.schedule_wrap 将回调调度到 Neovim 主线程
    -- 因为 uv.timer 的回调默认在 libuv 线程中运行
    -- 直接调用 vim.notify 等 Neovim API 会报错
    diag_timer:start(500, 0, vim.schedule_wrap(function()
      -- 获取该缓冲区的所有诊断项，返回一个 table
      local diagnostics = vim.diagnostic.get(buf)

      -- 诊断项总数
      local count = #diagnostics

      -- 如果没有诊断问题，弹出提示后直接返回
      if count == 0 then
        vim.notify("✅ 无诊断错误", vim.log.levels.INFO)
        return
      end

      -- 按严重程度分类计数
      local errors = 0    -- 错误数量
      local warnings = 0  -- 警告数量
      local hints = 0     -- 提示数量
      local info = 0      -- 信息数量

      -- 遍历所有诊断项，根据 severity 字段分类累加
      for _, d in ipairs(diagnostics) do
        if d.severity == vim.diagnostic.severity.ERROR then
          errors = errors + 1
        elseif d.severity == vim.diagnostic.severity.WARN then
          warnings = warnings + 1
        elseif d.severity == vim.diagnostic.severity.HINT then
          hints = hints + 1
        else
          -- 其余归为 info 级别
          info = info + 1
        end
      end

      -- 构建通知文本的各个部分
      -- 只有数量大于 0 的类别才会加入显示
      local parts = {}
      if errors > 0   then table.insert(parts, string.format("✘ %d 错误", errors)) end
      if warnings > 0 then table.insert(parts, string.format("▲ %d 警告", warnings)) end
      if info > 0     then table.insert(parts, string.format("» %d 信息", info)) end
      if hints > 0    then table.insert(parts, string.format("⚑ %d 提示", hints)) end

      -- 用两个空格拼接各分类，弹出通知
      -- 日志级别：有错误时用 ERROR 级别，否则用 WARN 级别
      vim.notify(
        "诊断: " .. table.concat(parts, "  "),
        errors > 0 and vim.log.levels.ERROR or vim.log.levels.WARN
      )
    end))
  end,
})