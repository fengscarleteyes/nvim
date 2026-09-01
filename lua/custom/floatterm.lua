-- lua/floatterm.lua
-- 浮动终端（Neovim 原生 API 实现）
--
-- 建议键位绑定（普通模式 + 终端模式各一份，才能真正"开关切换"）：
--   vim.keymap.set("n", "<C-t>", function() require("floatterm").toggle() end)
--   vim.keymap.set("t", "<C-t>", function() require("floatterm").toggle() end)
--   vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")  -- Esc 从终端模式退回普通模式
local M = {}

local float_win = nil -- 记录浮动窗口句柄
local float_buf = nil -- 记录终端 buffer 句柄

--- 打开浮动终端
function M.open()
  -- 如果窗口已存在且有效，直接聚焦
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_set_current_win(float_win)
    return
  end

  -- 创建终端 buffer
  float_buf = vim.api.nvim_create_buf(false, true)

  -- 计算浮动窗口大小（屏幕的 80% 宽，70% 高）
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- 创建浮动窗口
  float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal", -- 不显示边框装饰（可选 "minimal" 或去掉）
    border = "rounded", -- 圆角边框，可选: "none", "single", "double", "rounded", "solid", "shadow"
  })

  -- 根据操作系统选择 shell
  local shell
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    shell = vim.env.COMSPEC or "cmd.exe"
  else
    shell = vim.env.SHELL or "/bin/sh"
  end

  -- 在 buffer 中启动终端
  vim.fn.termopen(shell, {
    on_exit = function()
      -- 终端退出时自动关闭窗口和 buffer
      if float_win and vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_close(float_win, true)
      end
      if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
        pcall(vim.api.nvim_buf_delete, float_buf, { force = true })
      end
      float_win = nil
      float_buf = nil
    end,
  })

  -- 自动进入插入模式（终端需要插入模式才能输入）
  vim.cmd("startinsert")
end

--- 关闭浮动终端
function M.close()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    -- 关闭浮动窗口。force 必须传 true（等价 :close!）：
    -- nvim_win_close(win,false) 等价 :close，当它是某个"有未保存修改的 buffer"
    -- 的最后一个窗口时会报 E37/E948 被拦截（终端任务已退出等场景必然触发）。
    -- 传 true 可确保关闭，这也是 toggleterm.nvim 等插件的通行做法。
    vim.api.nvim_win_close(float_win, true)

    -- 结束后台 shell 进程并清除 buffer，避免多次 toggle 残留孤儿进程。
    -- 若希望关闭后保留终端会话（下次打开复用同一 shell），可删除下面这段。
    if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
      local job_id = vim.b[float_buf] and vim.b[float_buf].termjob_id
      if job_id then
        pcall(vim.fn.jobstop, job_id)
      end
      pcall(vim.api.nvim_buf_delete, float_buf, { force = true })
    end
  end
  float_win = nil
  float_buf = nil
end

--- 切换浮动终端（打开/关闭）
function M.toggle()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    M.close()
  else
    M.open()
  end
end

return M
