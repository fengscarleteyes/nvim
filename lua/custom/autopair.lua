-- autopair.lua
-- 自动补全成对字符（Auto Pair）。
--
-- 功能概览：
--   1. 自动补全：输入 ( [ { " ' ` 等开括号/引号时自动补全右半并让光标停在中间；
--   2. 智能闭合：输入闭括号时，若光标右侧正好是该闭括号则直接跳过而不是重复插入；
--   3. 智能退格：光标位于空对 () / "" 之间按退格时，一次删除整个对；
--   4. 引号启发式：" 这种首尾同字符的配对，默认只在“两侧都不是单词字符”时自动成对
--      （输入 it's 这类撇号时只插入单个引号）；
--   5. 开关（toggle）：可整体启用/禁用；禁用会移除全部插入映射，不影响其它插件；
--   6. 可自定义配对字符表（可动态增删）。
--
-- 标准插件写法：require 只返回 M 且本身不产生副作用，必须调用 M.setup(opts)
-- 才会注册插入映射与用户命令（入口 lua/custom/init.lua 已统一调用 setup）。
--
-- 用法（nvim 配置中；mapleader 需在 require/setup 之前设好）：
--   vim.g.mapleader = " "
--   local autopair = require("custom.autopair")
--   autopair.setup({                       -- 不调用 setup 则不会生效
--     enabled = true,
--     pairs = {                             -- 以默认表为底逐项覆盖
--       ["("] = ")", ["["] = "]", ["{"] = "}",
--       ['"'] = '"', ["'"] = "'", ["`"] = "`",
--       -- ["<"] = ">",                     -- 需要尖括号时可自行打开
--       -- ["'"] = false,                   -- 设为 false 表示“不要这一对”
--     },
--     smart_quotes    = true,               -- 引号类仅在两侧都不是单词时自动成对
--     skip_closing    = true,               -- 输入闭括号且右侧正好是它时跳过
--     bs_delete_pair  = true,               -- 空对之间退格一次删整对
--   })
--
-- 常用命令：
--   :AutoPairToggle   启用/禁用开关（来回切换）
--   :AutoPairEnable   启用
--   :AutoPairDisable  禁用
--
-- 常用键位（普通模式）：
--   vim.keymap.set("n", "<leader>ta", function() require("custom.autopair").toggle() end)
--
-- API：
--   autopair.setup(opts)                   合并配置、注册映射与用户命令（幂等）
--   autopair.is_enabled()                  是否启用
--   autopair.enable() / disable() / toggle()
--   autopair.add_pair(open, close)         新增/覆盖一个配对并即时生效
--   autopair.remove_pair(open)             移除一个配对并即时生效
--
-- 高级：
--   对个别文件/缓冲区单独关闭自动配对（全局开关仍可用）：
--     vim.b.autopair_enabled = false   -- 在某 autocmd 中针对当前 buffer 设置
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  enabled = true,
  pairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
    ["`"] = "`",
    ["*"] = "*",
  },
  smart_quotes = true, -- 首尾同字符的配对（引号）的“单词边不成对”启发式
  skip_closing = true, -- 闭括号右侧正好是它时跳过
  bs_delete_pair = true, -- 空对之间退格一次删整对
}

local cfg = vim.deepcopy(DEFAULTS)
local owned_insert = {} -- 我们注册过的插入模式按键（lhs 集合）
local commands_created = false
local ensure_commands -- 前置声明：M.setup() 会调用，函数体见下方「用户命令」一节

--- 合并配置：用户没给出的项沿用默认
local function merge(opts)
  opts = opts or {}
  cfg.enabled = DEFAULTS.enabled
  if opts.enabled ~= nil then
    cfg.enabled = opts.enabled
  end
  cfg.smart_quotes = DEFAULTS.smart_quotes
  if opts.smart_quotes ~= nil then
    cfg.smart_quotes = opts.smart_quotes
  end
  cfg.skip_closing = DEFAULTS.skip_closing
  if opts.skip_closing ~= nil then
    cfg.skip_closing = opts.skip_closing
  end
  cfg.bs_delete_pair = DEFAULTS.bs_delete_pair
  if opts.bs_delete_pair ~= nil then
    cfg.bs_delete_pair = opts.bs_delete_pair
  end

  -- pairs：以默认表为底，用户项覆盖；显式 false 表示删除该对
  cfg.pairs = {}
  for open, close in pairs(DEFAULTS.pairs) do
    cfg.pairs[open] = close
  end
  if type(opts.pairs) == "table" then
    for open, close in pairs(opts.pairs) do
      if close == false then
        cfg.pairs[open] = nil
      else
        cfg.pairs[open] = close
      end
    end
  end
end

--- 统计 UTF-8 字符串的字符数（Neovim 的 LuaJIT 没有内置 utf8 库，
--- 用“非连续字节数 = 码点数”的规律计算）
local function char_count(s)
  local n = select(2, s:gsub("[^\128-\191]", ""))
  return n
end

--- 校验一张 { open = close } 表：open/close 必须是单个 UTF-8 字符，
--- 且一个闭字符不能同时属于多个配对（引号类 open==close 除外）
--- @return table|nil, string|nil
local function sanitize(pairs_t)
  local out, seen_close, seen_open = {}, {}, {}
  for open, close in pairs(pairs_t) do
    if type(open) ~= "string" or type(close) ~= "string" then
      return nil, string.format("配对表项非法: %s", vim.inspect({ open, close }))
    end
    if char_count(open) ~= 1 then
      return nil, string.format("开字符必须为单个字符: %s", vim.inspect(open))
    end
    if char_count(close) ~= 1 then
      return nil, string.format("闭字符必须为单个字符: %s", vim.inspect(close))
    end
    if seen_open[open] then
      return nil, string.format("开字符重复注册: %s", vim.inspect(open))
    end
    if seen_close[close] and close ~= open then
      return nil, string.format("闭字符 %s 同时属于多个配对，不支持", vim.inspect(close))
    end
    out[open] = close
    seen_open[open] = true
    seen_close[close] = true
  end
  return out
end

-- ============================================================
-- 插入模式处理器（由 <expr> 映射调用，返回要“打出”的键序列文本）
-- 说明：返回的字符串由 nvim 按按键序列处理，文本形式 "<Left>" "<Right>"
--       "<BS>" "<Del>" 会被解释为对应按键；普通字符则直接插入且不会再
--       触发自身映射，因此这里可以放心地把被拒绝的字符原样返回。
-- ============================================================

--- 读取当前光标上下文
--- @return { before:string, under:string } 插入点左侧/右侧字符（可能为 ""）
local function get_ctx()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1] - 1, cur[2]
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
  local before, under = "", ""
  if col > 0 then
    before = string.sub(line, col, col) -- col 是 0 基，1 基下标同样为 col
  end
  under = string.sub(line, col + 1, col + 1)
  return { before = before, under = under }
end

--- 判断字符是否为“单词字符”（ASCII 字母/数字/下划线）
local function is_word_char(ch)
  return ch ~= "" and ch:match("[%w_]") ~= nil
end

--- 当前是否应执行配对动作：全局启用且该 buffer 未被单独关闭
local function active()
  if not cfg.enabled then
    return false
  end
  if vim.b.autopair_enabled == false then
    return false
  end
  return true
end

--- 输入“开字符”（如 '('、'"'），决定返回什么
local function ins_open(ch)
  if not active() then
    return ch
  end
  local close = cfg.pairs[ch]
  if not close then
    return ch
  end

  if ch == close then
    -- 引号类：右侧正好是同字符 -> 是已存在的闭号，跳过（防重复插入）
    if cfg.skip_closing and get_ctx().under == ch then
      return "<Right>"
    end
    -- 引号类：左侧或右侧是单词字符（如 it's、a'b 的撇号）只插入单个引号
    if cfg.smart_quotes then
      local ctx = get_ctx()
      if is_word_char(ctx.before) or is_word_char(ctx.under) then
        return ch
      end
    end
    return ch .. ch .. "<Left>"
  end

  -- 常规开括号：补全并回退一步让光标停在中间
  return ch .. close .. "<Left>"
end

--- 输入“闭字符”（如 ')'），决定返回什么
local function ins_close(ch)
  if not active() then
    return ch
  end
  if cfg.skip_closing and get_ctx().under == ch then
    return "<Right>"
  end
  return ch
end

--- 输入退格键，决定返回什么
local function ins_backspace()
  if not active() then
    return "<BS>"
  end
  if cfg.bs_delete_pair then
    local ctx = get_ctx()
    -- 左侧是开字符且右侧正好是它的闭字符 => 位于“空对”中间，一次删整对
    if ctx.before ~= "" and ctx.under ~= "" then
      local close = cfg.pairs[ctx.before]
      if close and close == ctx.under then
        return "<BS><Del>"
      end
    end
  end
  return "<BS>"
end

-- ============================================================
-- 插入模式映射的注册 / 卸载
-- ============================================================

--- 卸载我们注册过的插入模式映射（禁用或重建时调用）
local function clear_insert_maps()
  for _, lhs in ipairs(owned_insert) do
    pcall(vim.keymap.del, "i", lhs)
  end
  owned_insert = {}
end

--- 注册插入模式映射（仅在启用时调用；调用前应先 clear）
local function apply_insert_maps()
  clear_insert_maps()
  for open, close in pairs(cfg.pairs) do
    -- 引号类 open==close：同一个处理器统一判断 配对 / 跳过 / 只插单个
    vim.keymap.set("i", open, function()
      return ins_open(open)
    end, { expr = true })
    owned_insert[#owned_insert + 1] = open
    if open ~= close then
      vim.keymap.set("i", close, function()
        return ins_close(close)
      end, { expr = true })
      owned_insert[#owned_insert + 1] = close
    end
  end
  -- 空对退格
  vim.keymap.set("i", "<BS>", ins_backspace, { expr = true })
  owned_insert[#owned_insert + 1] = "<BS>"
end

-- ============================================================
-- 开关：启用 / 禁用 / 切换
-- ============================================================

local function notify_state()
  vim.notify("AutoPair: " .. (cfg.enabled and "已启用" or "已禁用"), vim.log.levels.INFO)
end

--- 配置或开关变化后统一刷新映射
local function refresh_maps()
  if cfg.enabled then
    apply_insert_maps()
  else
    clear_insert_maps()
  end
end

--- 启用自动配对
function M.enable()
  if cfg.enabled then
    return
  end
  cfg.enabled = true
  apply_insert_maps()
  notify_state()
end

--- 禁用自动配对（移除全部插入模式映射）
function M.disable()
  if not cfg.enabled then
    return
  end
  cfg.enabled = false
  clear_insert_maps()
  notify_state()
end

--- 开关切换
function M.toggle()
  if cfg.enabled then
    M.disable()
  else
    M.enable()
  end
end

--- 当前是否启用
function M.is_enabled()
  return cfg.enabled
end

-- ============================================================
-- 公共 API
-- ============================================================

--- 动态新增/覆盖一对字符
function M.add_pair(open, close)
  if cfg.pairs[open] and cfg.pairs[open] == close then
    return
  end
  local ok, err = sanitize({ [open] = close })
  if not ok then
    vim.notify("AutoPair.add_pair: " .. err, vim.log.levels.WARN)
    return false
  end
  cfg.pairs[open] = close
  refresh_maps()
  return true
end

--- 动态移除一对字符
function M.remove_pair(open)
  if not cfg.pairs[open] then
    return false
  end
  cfg.pairs[open] = nil
  refresh_maps()
  return true
end

--- 设置/覆盖配置并立即生效（可重复调用）；pairs 非法时回滚为默认配置
--- @param opts table|nil 见文件头部「用法」说明
--- @return table M
function M.setup(opts)
  opts = opts or {}
  merge(opts)

  local clean, err = sanitize(cfg.pairs)
  if not clean then
    merge() -- 回滚
    vim.notify("AutoPair.setup: " .. err, vim.log.levels.ERROR)
    return M
  end
  cfg.pairs = clean
  ensure_commands() -- 注册用户命令（内部幂等，重复 setup 不会重复创建）
  refresh_maps()
  return M
end

-- ============================================================
-- 用户命令
-- ============================================================

function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true
  vim.api.nvim_create_user_command("AutoPairToggle", function()
    M.toggle()
  end, { desc = "AutoPair: 启用/禁用开关" })
  vim.api.nvim_create_user_command("AutoPairEnable", function()
    M.enable()
  end, { desc = "AutoPair: 启用" })
  vim.api.nvim_create_user_command("AutoPairDisable", function()
    M.disable()
  end, { desc = "AutoPair: 禁用" })
end

return M
