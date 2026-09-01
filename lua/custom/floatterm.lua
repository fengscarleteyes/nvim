-- 浮动终端（Neovim 原生 API 实现）
--
-- API：
--   require("floatterm").toggle([cmd, opts])   切换开关（cmd 缺省为交互式 shell）
--   require("floatterm").run(cmd, [opts])      在浮动窗口运行指定命令
--   require("floatterm").open([cmd, opts])     打开（已打开且命令相同则聚焦，不同则重启）
--   require("floatterm").close()               关闭
--
-- cmd 说明：
--   * 字符串命令（如 "git status"）经系统 shell 执行，跨平台；
--   * 参数列表（如 {"python","-m","http.server","8000"}）直接作为 argv 执行。
-- opts 说明：
--   * close_on_exit = true：命令执行完自动关闭浮动窗口；
--     缺省：交互式 shell 退出即关（原行为），指定命令保留输出（可手动 toggle 关闭）。
--
-- 示例：
--   require("floatterm").run("git status", { close_on_exit = true })
--   require("floatterm").run("npm run dev")
--   require("floatterm").run({ "python", "-m", "http.server", "8000" })
--
-- 键位绑定建议（普通模式 + 终端模式各一份，才能真正"开关切换"）：
--   vim.keymap.set("n", "<C-t>", function() require("floatterm").toggle() end)
--   vim.keymap.set("t", "<C-t>", function() require("floatterm").toggle() end)
--   vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")  -- Esc 从终端模式退回普通模式
local M = {}

local float_win = nil -- 记录浮动窗口句柄
local float_buf = nil -- 记录终端 buffer 句柄
local current_cmd = nil -- 当前终端运行的命令（nil 表示交互式 shell）

--- 计算浮动窗口布局配置
local function float_config()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal", -- 不显示边框装饰（可选 "minimal" 或去掉）
    border = "rounded", -- 圆角边框，可选: "none", "single", "double", "rounded", "solid", "shadow"
  }
end

--- 根据操作系统选择 shell
local function get_shell()
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    return vim.env.COMSPEC or "cmd.exe"
  end
  return vim.env.SHELL or "/bin/sh"
end

--- 判断两次命令是否相同（支持字符串与参数列表）
local function same_cmd(a, b)
  if a == b then
    return true
  end
  return type(a) == "table" and type(b) == "table" and vim.deep_equal(a, b)
end

--- 打开浮动终端（内部实现，不做"已打开"判断）
--- @param cmd string|table|nil 要执行的命令；nil 或空串表示交互式 shell
--- @param opts table|nil 可选 { close_on_exit = boolean }
function M._open(cmd, opts)
  opts = opts or {}
  if cmd == "" then
    cmd = nil
  end
  current_cmd = cmd

  -- 创建终端 buffer
  float_buf = vim.api.nvim_create_buf(false, true)

  -- 创建浮动窗口
  float_win = vim.api.nvim_open_win(float_buf, true, float_config())

  -- 退出时是否自动关闭：
  -- 显式指定 close_on_exit 则遵循；否则交互式 shell 退出即关（原行为），
  -- 指定命令保留输出便于查看（可手动 toggle 关闭）。
  local auto_close = opts.close_on_exit
  if auto_close == nil then
    auto_close = (cmd == nil)
  end
  local bv = vim.b[float_buf] or {}
  bv.floatterm_close_on_exit = auto_close

  -- 启动终端：缺省启动交互式 shell，否则执行给定命令
  vim.fn.termopen(cmd or get_shell(), {
    on_exit = function()
      -- 仅当配置了"退出即关闭"时自动关闭并清理
      local should_close = float_buf and vim.b[float_buf] and vim.b[float_buf].floatterm_close_on_exit
      if should_close then
        if float_win and vim.api.nvim_win_is_valid(float_win) then
          vim.api.nvim_win_close(float_win, true)
        end
        if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
          pcall(vim.api.nvim_buf_delete, float_buf, { force = true })
        end
        float_win = nil
        float_buf = nil
        current_cmd = nil
      end
    end,
  })

  -- 自动进入插入模式（终端需要插入模式才能输入）
  vim.cmd("startinsert")
end

--- 打开浮动终端；已打开时命令相同则聚焦，命令不同则重启
--- @param cmd string|table|nil 要执行的命令
--- @param opts table|nil 可选 { close_on_exit = boolean }
function M.open(cmd, opts)
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    if same_cmd(current_cmd, cmd) then
      vim.api.nvim_set_current_win(float_win)
      return
    end
    M.close()
  end
  M._open(cmd, opts)
end

--- 在浮动窗口运行指定命令（等效 M.open(cmd, opts)）
function M.run(cmd, opts)
  M.open(cmd, opts)
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
  current_cmd = nil
end

--- 切换浮动终端（打开/关闭）
--- @param cmd string|table|nil 打开时执行的命令（nil 为交互式 shell）
--- @param opts table|nil 可选 { close_on_exit = boolean }
function M.toggle(cmd, opts)
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    M.close()
  else
    M._open(cmd, opts)
  end
end

return M
