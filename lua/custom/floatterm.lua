-- lua/custom/floatterm.lua
-- 浮动终端（Neovim 原生 API 实现；标准插件写法：返回 M，由 M.setup() 生效）
--
-- API：
--   require("custom.floatterm").setup([opts])       合并配置并绑定默认键位（幂等）
--   require("custom.floatterm").toggle([cmd, opts]) 切换开关（cmd 缺省为交互式 shell）
--   require("custom.floatterm").run(cmd, [opts])    在浮动窗口运行指定命令
--   require("custom.floatterm").open([cmd, opts])   打开（已打开且命令相同则聚焦，不同则重启）
--   require("custom.floatterm").close()             关闭
--
-- 默认键位（调用 setup 后生效，普通模式与终端模式各一份才能真正"开关切换"）：
--   <C-\>  普通模式 / 终端模式：打开或关闭浮动终端
--   <Esc>  终端模式：直接关闭浮动终端
--
-- cmd 说明：
--   * 字符串命令（如 "git status"）经系统 shell 执行，跨平台；
--   * 参数列表（如 {"python","-m","http.server","8000"}）直接作为 argv 执行。
-- 配置（M.setup(opts)）：
--   map_keys     boolean  true        是否绑定默认键位（false 只加载功能）
--   width_ratio  number   0.8         浮动窗口宽度占比（相对 editor）
--   height_ratio number   0.7         浮动窗口高度占比（相对 editor）
--   border       string   "rounded"   边框样式，见 :h nvim_open_win
--   shell        string   nil         默认 shell；nil 表示按系统自动探测
--
-- opts 说明：
--   * close_on_exit（默认 true）：命令/终端退出后自动关闭浮动窗口，
--     避免停留在 [Process exited N] 无法完全退出；
--     设 false 则保留窗口便于查看输出（可手动 toggle 关闭）。
--
-- 示例：
--   require("custom.floatterm").run("git status")                         -- 跑完自动关闭
--   require("custom.floatterm").run("pip list", { close_on_exit = false }) -- 保留输出
--   require("custom.floatterm").run("npm run dev")
--   require("custom.floatterm").run({ "python", "-m", "http.server", "8000" })
local M = {}

--- 默认配置
local DEFAULTS = {
  map_keys = true,
  width_ratio = 0.8,
  height_ratio = 0.7,
  border = "rounded",
  shell = nil, -- nil 表示按系统自动探测
}

local cfg = vim.deepcopy(DEFAULTS)

local float_win = nil -- 记录浮动窗口句柄
local float_buf = nil -- 记录终端 buffer 句柄
local current_cmd = nil -- 当前终端运行的命令（nil 表示交互式 shell）

--- 计算浮动窗口布局配置
local function float_config()
  local width = math.floor(vim.o.columns * cfg.width_ratio)
  local height = math.floor(vim.o.lines * cfg.height_ratio)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal", -- 不显示边框装饰（可选 "minimal" 或去掉）
    border = cfg.border, -- 圆角边框，可选: "none", "single", "double", "rounded", "solid", "shadow"
  }
end

--- 选择 shell：优先使用配置，否则按操作系统自动探测
local function get_shell()
  if cfg.shell then
    return cfg.shell
  end
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    return "powershell.exe"
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
local function open_float(cmd, opts)
  opts = opts or {}
  if cmd == "" then
    cmd = nil
  end
  current_cmd = cmd

  -- 创建终端 buffer
  float_buf = vim.api.nvim_create_buf(false, true)

  -- 创建浮动窗口
  float_win = vim.api.nvim_open_win(float_buf, true, float_config())

  -- 退出时是否自动关闭：默认 true（命令/终端退出后自动关闭浮动窗口，
  -- 避免停留在 [Process exited N] 无法完全退出）。
  -- 需要保留输出查看时显式传 { close_on_exit = false }。
  local auto_close = opts.close_on_exit ~= false
  local bv = vim.b[float_buf] or {}
  bv.floatterm_close_on_exit = auto_close

  -- 启动终端：缺省启动交互式 shell，否则执行给定命令
  -- 注：termopen() 已弃用（:h deprecated），改用 jobstart() 的 term 选项
  vim.fn.jobstart(cmd or get_shell(), {
    term = true,
    on_exit = function()
      -- 仅当配置了"退出即关闭"时自动关闭并清理
      local should_close = float_buf and vim.b[float_buf] and vim.b[float_buf].floatterm_close_on_exit
      if should_close then
        if float_win and vim.api.nvim_win_is_valid(float_win) then
          pcall(vim.api.nvim_win_close, float_win, true)
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
  open_float(cmd, opts)
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
    open_float(cmd, opts)
  end
end

-- ============================================================
-- 默认键位（由入口调用 M.setup() 后生效）
-- ============================================================

--- 默认键位表：模式 / 按键 / 动作 / 描述
local DEFAULT_KEYMAPS = {
  { mode = "n", lhs = "<C-\\>", action = function() M.toggle() end, desc = "Toggle floating terminal" },
  { mode = "t", lhs = "<C-\\>", action = function() M.toggle() end, desc = "Toggle floating terminal" },
  { mode = "t", lhs = "<Esc>", action = function() M.close() end, desc = "Close floating terminal" },
}

local initialized = false -- setup() 是否已完成注册

--- 合并配置并绑定默认键位（幂等：重复调用只绑定一次）
--- 普通模式与终端模式都绑 <C-\>，才能真正"开关切换"；
--- 终端模式的 <Esc> 用于直接关闭浮动终端（而不是退回普通模式）。
--- @param opts table|nil 见文件头部「配置」说明；map_keys = false 表示只加载功能、不绑键位
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  if initialized or not cfg.map_keys then
    return M
  end
  initialized = true
  for _, map in ipairs(DEFAULT_KEYMAPS) do
    vim.keymap.set(map.mode, map.lhs, map.action, { desc = map.desc })
  end
  return M
end

return M
