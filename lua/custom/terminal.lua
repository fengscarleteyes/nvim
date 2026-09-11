-- lua/custom/terminal.lua
-- 终端（Neovim 原生 API 实现；标准插件写法：返回 M，由 M.setup() 生效）
-- 支持三种布局，可任选其一（opts.layout / cfg.layout，默认 float）：
--   float   浮动窗口：居中显示，宽度 columns*0.8、高度 lines*0.7（可配）
--   right   右侧对半分割：垂直分割，宽度占 columns 的 50%
--   bottom  底部 1/3 高度分割：水平分割，高度占可用高度的 1/3
--
-- API：
--   require("custom.terminal").setup([opts])         合并配置并绑定默认键位（幂等）
--   require("custom.terminal").toggle([cmd, opts])   切换开关（已打开即关闭，否则按布局打开）
--   require("custom.terminal").open([cmd, opts])     打开（已打开且布局+命令相同则聚焦，否则重启）
--   require("custom.terminal").run(cmd, [opts])      等价 open（语义化别名）
--   require("custom.terminal").close()               关闭
--   require("custom.terminal").layout()              当前终端布局（未打开时返回 nil）
--
-- 布局选择：opts.layout = "float" | "right" | "bottom"，缺省用配置项 cfg.layout。
--   例：require("custom.terminal").toggle(nil, { layout = "right" })
--
-- 默认键位（调用 setup 后生效；普通模式与终端模式各绑一份才能真正“开关切换”）：
--   <C-\>          普通 / 终端模式：切换默认布局（float）
--   <leader>tr     普通 / 终端模式：切换右侧对半分割
--   <leader>tb     普通 / 终端模式：切换底部 1/3 分割
--   <Esc>          终端模式：关闭（而不是退回普通模式）
--
-- 用户命令：
--   :TerminalToggle  :TerminalFloat  :TerminalRight  :TerminalBottom  :TerminalClose
--
-- cmd 说明：
--   * 字符串命令（如 "git status"）经系统 shell 执行，跨平台；
--   * 参数列表（如 {"python","-m","http.server","8000"}）直接作为 argv 执行。
--
-- 配置（M.setup(opts)）：
--   layout    string   "float"   默认布局：float / right / bottom
--   shell     string   nil       默认 shell；nil 表示按系统自动探测
--   map_keys  boolean  true      是否绑定默认键位（false 只注册命令、不绑键位）
--   keys = {                      -- lhs 设 false 或 "" 即不绑定该键
--     float  = "<C-\\>"          切换浮动窗口（普通 + 终端模式）
--     right  = "<leader>tr"      切换右侧对半分割（普通 + 终端模式）
--     bottom = "<leader>tb"      切换底部 1/3 分割（普通 + 终端模式）
--     close  = "<Esc>"           终端模式关闭
--   }
--   layouts = {                   -- 各布局的几何参数
--     float  = { width_ratio = 0.8, height_ratio = 0.7, border = "rounded" },
--     right  = { width_ratio = 0.5 },      -- 对半：占 columns 50%
--     bottom = { height_ratio = 1 / 3 },   -- 占可用高度 1/3
--   }
--   win_opts = {                  -- 仅作用于 right / bottom 分割窗口
--     number = false, relativenumber = false, signcolumn = "no",
--   }
--
-- opts 说明（M.open / M.run / M.toggle 的第二个参数）：
--   * layout         string|nil   本次使用的布局；nil 表示用 cfg.layout
--   * close_on_exit  boolean|nil  命令/终端退出后是否自动关闭（默认 true）；
--     设 false 则保留窗口便于查看输出（可手动 toggle/close 关闭）。
--     注意：分割布局保留窗口时会一直占位，必要时自行 :close。
--
-- 示例：
--
-- 1) 配置：setup 与默认配置深合并，只写需要改的项（可反复调用，键位只绑一次）
--   require("custom.terminal").setup({
--     layout = "bottom", -- 默认布局："float" | "right" | "bottom"
--     shell = "pwsh", -- 例：指定 shell；nil 表示按系统自动探测
--     keys = {
--       float = "<C-\\>", -- 浮动窗口（普通 + 终端模式）
--       right = "<leader>tr", -- 右侧对半分割
--       bottom = false, -- 不绑该键（仍可用 :TerminalBottom）
--       close = "<Esc>", -- 终端模式关闭
--     },
--     layouts = {
--       float = { width_ratio = 0.9, height_ratio = 0.85, border = "double" },
--       right = { width_ratio = 0.4 }, -- 右侧占 columns 的 40%
--       bottom = { height_ratio = 0.25 }, -- 底部占可用高度的 25%
--     },
--     win_opts = { number = true }, -- 分割窗口保留行号（默认关闭）
--   })
--
-- 2) 只注册命令、不绑键位；键位完全自定义（适合写进 lua/keymaps/init.lua）
--   require("custom.terminal").setup({ map_keys = false })
--   vim.keymap.set({ "n", "t" }, "<F5>", function() -- 自己绑：右侧对半
--     require("custom.terminal").toggle(nil, { layout = "right" })
--   end, { desc = "Terminal: right split" })
--
-- 3) 交互式 shell 与布局查询（cmd 传 nil / "" 即交互式 shell）
--   require("custom.terminal").toggle(nil, { layout = "bottom" }) -- 打开底部 1/3 的交互式 shell
--   require("custom.terminal").layout() -- "float" | "right" | "bottom" | nil（未打开）
--   require("custom.terminal").toggle() -- 已打开 => 关闭
--   require("custom.terminal").open(nil, { layout = "right" }) -- 布局+命令相同 => 聚焦，不重建
--
-- 4) 常见集成：close_on_exit = false 让输出/会话留在窗口里
--   require("custom.terminal").run("lazygit", { close_on_exit = false }) -- 浮动常驻 lazygit
--   vim.keymap.set("n", "<leader>tt", function() -- 底部 1/3 跑测试并保留输出
--     require("custom.terminal").toggle("pytest -q", { layout = "bottom", close_on_exit = false })
--   end, { desc = "Terminal: pytest" })
--   vim.api.nvim_create_user_command("Tlog", function() -- 底部 1/3 看 git log
--     require("custom.terminal").toggle("git log --oneline -50", { layout = "bottom" })
--   end, { desc = "Terminal: git log" })
--
-- 5) 跑命令速查（cmd 可为字符串[经 shell] 或 argv 列表[不经 shell]）
--   require("custom.terminal").run("git status")                           -- 浮动，跑完自动关闭
--   require("custom.terminal").run("pip list", { close_on_exit = false })  -- 保留输出
--   require("custom.terminal").run("npm run dev", { layout = "right" })    -- 右侧对半
--   require("custom.terminal").toggle(nil, { layout = "bottom" })          -- 底部 1/3 开关
--   require("custom.terminal").run({ "python", "-m", "http.server", "8000" })
local M = {}

--- 默认配置
local DEFAULTS = {
  layout = "float", -- 默认布局
  shell = nil, -- nil 表示按系统自动探测
  map_keys = true, -- 是否绑定默认键位
  keys = {
    float = "<C-\\>",
    right = "<leader>tr",
    bottom = "<leader>tb",
    close = "<Esc>",
  },
  layouts = {
    float = { width_ratio = 0.8, height_ratio = 0.7, border = "rounded" },
    right = { width_ratio = 0.5 }, -- 右侧对半
    bottom = { height_ratio = 1 / 3 }, -- 底部 1/3 高度
  },
  win_opts = { -- 仅作用于分割终端窗口
    number = false,
    relativenumber = false,
    signcolumn = "no",
  },
}

local cfg = vim.deepcopy(DEFAULTS)

local term_win = nil -- 终端窗口句柄（浮动或分割）
local term_buf = nil -- 终端 buffer 句柄
local current_cmd = nil -- 当前终端运行的命令（nil 表示交互式 shell）
local current_layout = nil -- 当前终端布局："float" | "right" | "bottom"

--- 支持的布局
local LAYOUT_NAMES = { "float", "right", "bottom" }

--- 判断布局名是否合法
local function is_valid_layout(name)
  for _, item in ipairs(LAYOUT_NAMES) do
    if item == name then
      return true
    end
  end
  return false
end

--- 解析布局名：缺省用默认布局；非法值告警并回退到默认布局
local function resolve_layout(layout)
  if layout == nil then
    layout = cfg.layout
  end
  if is_valid_layout(layout) then
    return layout
  end
  local fallback = is_valid_layout(DEFAULTS.layout) and DEFAULTS.layout or "float"
  vim.notify(string.format('Terminal: 未知布局 %s，改用 "%s"', vim.inspect(layout), fallback), vim.log.levels.WARN)
  return fallback
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

--- 终端当前是否已打开
local function is_open()
  return term_win ~= nil and vim.api.nvim_win_is_valid(term_win)
end

--- 创建浮动窗口（居中；尺寸与边框按 layouts.float）
--- @param buf integer 终端 buffer
--- @return integer 窗口句柄
local function create_float_win(buf)
  local layout = cfg.layouts.float
  local width = math.max(1, math.floor(vim.o.columns * layout.width_ratio))
  local height = math.max(1, math.floor(vim.o.lines * layout.height_ratio))
  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal", -- 不显示边框装饰（行号、状态列等）
    border = layout.border, -- 边框: "none" | "single" | "double" | "rounded" | "solid" | "shadow"
  })
end

--- 创建分割窗口并设置尺寸
---   right  = 右侧对半：垂直分割，宽度 = columns * layouts.right.width_ratio
---   bottom = 底部 1/3：水平分割，高度 = 可用高度 * layouts.bottom.height_ratio
--- @param buf integer 终端 buffer
--- @param layout string "right" | "bottom"
--- @return integer 窗口句柄
local function create_split_win(buf, layout)
  local win
  if layout == "right" then
    vim.cmd("botright vsplit") -- 新窗口落在最右侧
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    local width = math.max(1, math.floor(vim.o.columns * cfg.layouts.right.width_ratio))
    vim.api.nvim_win_set_width(win, width)
  else
    vim.cmd("botright split") -- 新窗口落在最底部
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    -- 可用高度需扣除命令行（cmdheight）
    local avail = math.max(1, vim.o.lines - vim.o.cmdheight)
    local height = math.max(1, math.floor(avail * cfg.layouts.bottom.height_ratio))
    vim.api.nvim_win_set_height(win, height)
  end

  -- 分割窗口按 win_opts 配置（默认去掉行号等，保持“终端面板”观感）
  for opt, value in pairs(cfg.win_opts or {}) do
    pcall(vim.api.nvim_set_option_value, opt, value, { win = win })
  end
  return win
end

--- 打开终端（内部实现，不做“已打开”判断）
--- @param cmd string|table|nil 要执行的命令；nil 或空串表示交互式 shell
--- @param opts table|nil 可选 { layout = string, close_on_exit = boolean }
local function open_term(cmd, opts)
  opts = opts or {}
  local layout = resolve_layout(opts.layout)
  if cmd == "" then
    cmd = nil
  end
  current_cmd = cmd
  current_layout = layout

  -- 创建终端 buffer
  local buf = vim.api.nvim_create_buf(false, true)
  term_buf = buf

  -- 按布局创建窗口：float 浮动，right / bottom 分割
  if layout == "float" then
    term_win = create_float_win(buf)
  else
    term_win = create_split_win(buf, layout)
  end

  -- 退出时是否自动关闭：默认 true（命令/终端退出后自动关闭窗口，
  -- 避免停留在 [Process exited N] 无法完全退出）。
  -- 需要保留输出查看时显式传 { close_on_exit = false }。
  local auto_close = opts.close_on_exit ~= false

  -- 启动终端：缺省启动交互式 shell，否则执行给定命令
  -- 注：termopen() 已弃用（:h deprecated），改用 jobstart() 的 term 选项
  vim.fn.jobstart(cmd or get_shell(), {
    term = true,
    on_exit = function()
      -- 仅当配置了“退出即关闭”，且该 buffer 仍是当前终端时才清理；
      -- 避免被后开终端取代的旧任务退出时误关新窗口
      if not auto_close or term_buf ~= buf then
        return
      end
      if term_win and vim.api.nvim_win_is_valid(term_win) then
        pcall(vim.api.nvim_win_close, term_win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
      term_win, term_buf, current_cmd, current_layout = nil, nil, nil, nil
    end,
  })

  -- 自动进入插入模式（终端需要插入模式才能输入）
  vim.cmd("startinsert")
end

--- 打开终端；已打开时布局与命令都相同则聚焦，否则重启
--- @param cmd string|table|nil 要执行的命令
--- @param opts table|nil 可选 { layout = string, close_on_exit = boolean }
--- @return integer|nil 终端窗口句柄
function M.open(cmd, opts)
  opts = opts or {}
  local layout = resolve_layout(opts.layout)
  if is_open() then
    if current_layout == layout and same_cmd(current_cmd, cmd) then
      vim.api.nvim_set_current_win(term_win)
      vim.cmd("startinsert")
      return term_win
    end
    M.close()
  end
  open_term(cmd, opts)
  return term_win
end

--- 在终端运行指定命令（等价 M.open(cmd, opts)，语义化别名）
--- @param cmd string|table|nil 要执行的命令
--- @param opts table|nil 可选 { layout = string, close_on_exit = boolean }
--- @return integer|nil 终端窗口句柄
function M.run(cmd, opts)
  return M.open(cmd, opts)
end

--- 关闭终端
function M.close()
  if is_open() then
    -- 关闭窗口。force 必须传 true（等价 :close!）：
    -- nvim_win_close(win,false) 等价 :close，当它是某个"有未保存修改的 buffer"
    -- 的最后一个窗口时会报 E37/E948 被拦截（终端任务已退出等场景必然触发）。
    -- 传 true 可确保关闭，这也是 toggleterm.nvim 等插件的通行做法。
    vim.api.nvim_win_close(term_win, true)

    -- 结束后台 shell 进程并清除 buffer，避免多次 toggle 残留孤儿进程。
    -- 若希望关闭后保留终端会话（下次打开复用同一 shell），可删除下面这段。
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      local job_id = vim.b[term_buf] and vim.b[term_buf].termjob_id
      if job_id then
        pcall(vim.fn.jobstop, job_id)
      end
      pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
    end
  end
  term_win, term_buf, current_cmd, current_layout = nil, nil, nil, nil
end

--- 切换终端（已打开则关闭，否则按布局打开）
--- @param cmd string|table|nil 打开时执行的命令（nil 为交互式 shell）
--- @param opts table|nil 可选 { layout = string, close_on_exit = boolean }
function M.toggle(cmd, opts)
  if is_open() then
    M.close()
  else
    open_term(cmd, opts)
  end
end

--- 当前终端布局（未打开时返回 nil）
--- @return string|nil "float" | "right" | "bottom"
function M.layout()
  if is_open() then
    return current_layout
  end
  return nil
end

-- ============================================================
-- 默认键位与用户命令（由入口调用 M.setup() 后生效）
-- ============================================================

--- 生成默认键位表：lhs 为 false / "" 的项会被跳过
--- 普通模式与终端模式都绑，才能真正“开关切换”；
--- 终端模式的 close 键用于直接关闭终端（而不是退回普通模式）。
local function build_keymaps()
  local keys = cfg.keys or {}
  local function toggle(layout)
    return function()
      M.toggle(nil, { layout = layout })
    end
  end
  local candidates = {
    { mode = { "n", "t" }, lhs = keys.float, action = toggle("float"), desc = "Terminal: toggle float" },
    { mode = { "n", "t" }, lhs = keys.right, action = toggle("right"), desc = "Terminal: toggle right split" },
    { mode = { "n", "t" }, lhs = keys.bottom, action = toggle("bottom"), desc = "Terminal: toggle bottom split" },
    { mode = "t", lhs = keys.close, action = function() M.close() end, desc = "Terminal: close" },
  }

  local maps = {}
  for _, map in ipairs(candidates) do
    if type(map.lhs) == "string" and map.lhs ~= "" then
      maps[#maps + 1] = map
    end
  end
  return maps
end

local commands_created = false

--- 注册用户命令（幂等）
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true
  vim.api.nvim_create_user_command("TerminalToggle", function()
    M.toggle()
  end, { desc = "Terminal: 切换（默认布局）" })
  vim.api.nvim_create_user_command("TerminalFloat", function()
    M.toggle(nil, { layout = "float" })
  end, { desc = "Terminal: 切换浮动窗口" })
  vim.api.nvim_create_user_command("TerminalRight", function()
    M.toggle(nil, { layout = "right" })
  end, { desc = "Terminal: 切换右侧对半分割" })
  vim.api.nvim_create_user_command("TerminalBottom", function()
    M.toggle(nil, { layout = "bottom" })
  end, { desc = "Terminal: 切换底部 1/3 高度分割" })
  vim.api.nvim_create_user_command("TerminalClose", function()
    M.close()
  end, { desc = "Terminal: 关闭" })
end

local initialized = false -- setup() 是否已完成注册

--- 合并配置并注册命令/键位（幂等：键位只绑定一次）
--- @param opts table|nil 见文件头部「配置」说明；map_keys = false 表示只注册命令、不绑键位
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  ensure_commands() -- 命令与 map_keys 无关，始终注册
  if initialized or not cfg.map_keys then
    return M
  end
  initialized = true
  for _, map in ipairs(build_keymaps()) do
    vim.keymap.set(map.mode, map.lhs, map.action, { desc = map.desc })
  end
  return M
end

return M
