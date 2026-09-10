-- autopair.lua
-- 自动补全成对字符（Auto Pair），并支持在配对的 外部开头 / 内部中间 / 外部结束 之间跳转。
--
-- 功能概览：
--   1. 自动补全：输入 ( [ { " ' ` 等开括号/引号时自动补全右半并让光标停在中间；
--   2. 智能闭合：输入闭括号时，若光标右侧正好是该闭括号则直接跳过而不是重复插入；
--   3. 智能退格：光标位于空对 () / "" 之间按退格时，一次删除整个对；
--   4. 引号启发式：" 这种首尾同字符的配对，默认只在“两侧都不是单词字符”时自动成对
--      （输入 it's 这类撇号时只插入单个引号）；
--   5. 开关（toggle）：可整体启用/禁用；禁用会移除全部插入映射，不影响其它插件；
--   6. 可自定义配对字符表（可动态增删）；
--   7. 跳转快捷键：在当前行内找到光标所处（或最近）的一对字符，跳到
--      外部开头（开括号左侧）/ 内部中间 / 外部结束（闭括号右侧），
--      默认键可整体/逐项禁用与自定义。
--
-- 用法（nvim 配置中；mapleader 需在 require/setup 之前设好）：
--   vim.g.mapleader = " "
--   local autopair = require("autopair")   -- 不调用 setup 也会按默认配置生效
--   autopair.setup({
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
--     keys = {                              -- 跳转键；某项或整体设 false 即禁用
--       outer_start  = "<leader>ps",        -- 配对的外部开头（开括号左侧）
--       inner_middle = "<leader>pm",        -- 配对的内部中间
--       outer_end    = "<leader>pe",        -- 配对的外部结束（闭括号右侧）
--     },
--   })
--
-- 常用命令：
--   :AutoPairToggle   启用/禁用开关（来回切换）
--   :AutoPairEnable   启用          :AutoPairDisable  禁用
--   :AutoPairJumpStart / Inside / End  对应三种位置跳转
--
-- 常用键位（普通模式）：
--   vim.keymap.set("n", "<leader>ta", function() require("autopair").toggle() end)
--
-- API：
--   autopair.is_enabled()                  是否启用
--   autopair.enable() / disable() / toggle()
--   autopair.add_pair(open, close)         新增/覆盖一个配对并即时生效
--   autopair.remove_pair(open)             移除一个配对并即时生效
--   autopair.jump_outer_start()            跳到外部开头（开括号左侧）
--   autopair.jump_inner_middle()           跳到内部中间
--   autopair.jump_outer_end()              跳到外部结束（闭括号右侧）
--   autopair.jump(which)                   通用跳转 which 同上三者之一
--   autopair.map_jump(name, keys)          自定义跳转键；keys=false 卸载
--
-- 高级：
--   对个别文件/缓冲区单独关闭自动配对（全局开关仍可用）：
--     vim.b.autopair_enabled = false   -- 在某 autocmd 中针对当前 buffer 设置
--
-- 跳转语义（作用于光标所在行，只处理同行内闭合的一对）：
--   1) 光标在某对内部（含紧贴其闭括号）时，作用于【最内层】包含光标的对；
--   2) 否则向右找开括号在光标右侧最近的一对；
--   3) 右侧没有则向左找最近结束的一对。
-- 三个目标位置：
--   外部开头 = 开括号所在列（插入点在开括号左侧）
--   内部中间 = 开括号之后内容的中点（空对即紧贴开括号之后）
--   外部结束 = 闭括号之后一列（插入点在闭括号右侧）
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
  },
  smart_quotes = true, -- 首尾同字符的配对（引号）的“单词边不成对”启发式
  skip_closing = true, -- 闭括号右侧正好是它时跳过
  bs_delete_pair = true, -- 空对之间退格一次删整对
  keys = {
    outer_start = "<leader>ps",
    inner_middle = "<leader>pm",
    outer_end = "<leader>pe",
  },
}

local cfg = vim.deepcopy(DEFAULTS)
local configured = false -- setup() 是否已被调用
local owned_insert = {} -- 我们注册过的插入模式按键（lhs 集合）
local applied_jumps = {} -- 已生效的跳转键 { name = lhs }
local commands_created = false

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

  -- keys：整体 false 关闭全部跳转键；表格则逐项覆盖/禁用
  if opts.keys == false then
    cfg.keys = false
  else
    cfg.keys = {}
    for name, key in pairs(DEFAULTS.keys) do
      cfg.keys[name] = key
    end
    if type(opts.keys) == "table" then
      for name, key in pairs(opts.keys) do
        cfg.keys[name] = key or nil -- false/nil 都视为不绑定
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
-- 配对解析与跳转（仅处理光标当前行）
-- ============================================================

--- 反向表 close -> open（由当前配对表生成）
local function build_reverse()
  local rev = {}
  for open, close in pairs(cfg.pairs) do
    rev[close] = open
  end
  return rev
end

--- 把一行解析成若干“闭合配对” { open=开列, close=闭列 }（0 基字节列）。
--- 用栈做平衡匹配；闭合符到达时，其上方仍未闭合的内容（例如字符串里的
--- 括号）会被丢弃，从而避免错配。
--- @param line string
--- @return table[]
local function parse_line_pairs(line)
  local res = {}
  local rev = build_reverse()
  local stack = {}
  local pos, n = 0, #line
  while pos < n do
    local b = string.byte(line, pos + 1)
    local len = 1
    if b and b >= 0xF0 then
      len = 4
    elseif b and b >= 0xE0 then
      len = 3
    elseif b and b >= 0xC0 then
      len = 2
    end
    local ch = line:sub(pos + 1, pos + len)

    if rev[ch] then
      -- 可能是闭字符：自顶向下找它对应的开字符
      local match = nil
      for k = #stack, 1, -1 do
        if stack[k].open == rev[ch] then
          match = k
          break
        end
      end
      if match then
        res[#res + 1] = { open = stack[match].idx, close = pos }
        -- 弹出到并包括 match：其上方未闭合的内容视为“字符串噪音”丢弃
        for k = #stack, match, -1 do
          stack[k] = nil
        end
      elseif cfg.pairs[ch] then
        -- 引号类开==闭的字符：若栈中没有等待闭合的同字符，则视为开
        stack[#stack + 1] = { open = ch, idx = pos }
      end
    elseif cfg.pairs[ch] then
      stack[#stack + 1] = { open = ch, idx = pos }
    end

    pos = pos + len
  end
  return res
end

--- 依据光标列 col 挑选“要操作的那一对”
--- @return { open:number, close:number }|nil
local function pick_pair(col, list)
  -- 1) 包含光标的对：open < col 且 close >= col，取跨度最小的（最内层）
  local best = nil
  for _, p in ipairs(list) do
    if p.open < col and col <= p.close then
      local span = p.close - p.open
      if not best or span < (best.close - best.open) or (span == (best.close - best.open) and p.open > best.open) then
        best = p
      end
    end
  end
  if best then
    return best
  end

  -- 2) 光标右侧最近的一对：开括号在光标右侧，取开括号最靠左的
  best = nil
  for _, p in ipairs(list) do
    if p.open >= col and (not best or p.open < best.open) then
      best = p
    end
  end
  if best then
    return best
  end

  -- 3) 光标左侧最近结束的一对：闭括号已在其左侧，取闭括号最靠右的
  best = nil
  for _, p in ipairs(list) do
    if p.close < col and (not best or p.close > best.close) then
      best = p
    end
  end
  return best
end

--- 计算目标列：which ∈ "outer_start" | "inner_middle" | "outer_end"
local function target_col(p, which)
  if which == "outer_start" then
    return p.open
  elseif which == "outer_end" then
    return p.close + 1
  end
  -- inner_middle：开括号之后内容的中点；空对则紧贴开括号之后
  local content_len = p.close - p.open - 1
  if content_len <= 0 then
    return p.open + 1
  end
  return p.open + 1 + math.floor(content_len / 2)
end

--- 执行一次跳转（写光标列）
--- @return boolean 是否成功
local function jump(which)
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1] - 1, cur[2]
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
  local pairs = parse_line_pairs(line)
  local p = pick_pair(col, pairs)
  if not p then
    vim.notify("AutoPair: 当前行没有可跳转的配对", vim.log.levels.INFO)
    return false
  end
  local target = target_col(p, which)
  local max_col = #line
  if target < 0 then
    target = 0
  end
  if target > max_col then
    target = max_col
  end
  vim.api.nvim_win_set_cursor(0, { row + 1, target })
  return true
end

-- ============================================================
-- 跳转快捷键的注册 / 卸载
-- ============================================================

local JUMP_NAMES = { "outer_start", "inner_middle", "outer_end" }

local function clear_jump_maps()
  for name, lhs in pairs(applied_jumps) do
    pcall(vim.keymap.del, "n", lhs)
    applied_jumps[name] = nil
  end
end

--- 按 cfg.keys 绑定跳转键（普通模式 n）
local function apply_jump_maps()
  clear_jump_maps()
  if cfg.keys == false then
    return
  end
  for _, name in ipairs(JUMP_NAMES) do
    local lhs = cfg.keys[name]
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, function()
        jump(name)
      end, {
        desc = "AutoPair: 跳到配对 " .. name,
      })
      applied_jumps[name] = lhs
    end
  end
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
  apply_jump_maps() -- 跳转键与开关无关，始终生效
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

--- 禁用自动配对（移除插入模式映射；跳转功能仍可用）
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

--- 跳转 API：跳到配对的外部开头 / 内部中间 / 外部结束
--- @return boolean 是否成功
function M.jump_outer_start()
  return jump("outer_start")
end

function M.jump_inner_middle()
  return jump("inner_middle")
end

function M.jump_outer_end()
  return jump("outer_end")
end

--- 通用跳转：which ∈ "outer_start" | "inner_middle" | "outer_end"
--- @return boolean
function M.jump(which)
  for _, name in ipairs(JUMP_NAMES) do
    if name == which then
      return jump(which)
    end
  end
  vim.notify("AutoPair: 未知跳转目标 " .. vim.inspect(which), vim.log.levels.WARN)
  return false
end

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

--- 自定义/卸载某个跳转键；keys=false 卸载
function M.map_jump(name, keys)
  local valid = false
  for _, n in ipairs(JUMP_NAMES) do
    if n == name then
      valid = true
    end
  end
  if not valid then
    vim.notify("AutoPair.map_jump: 未知名称 " .. vim.inspect(name), vim.log.levels.WARN)
    return false
  end
  if keys == false then
    if cfg.keys ~= false then
      cfg.keys[name] = nil
    end
  else
    if cfg.keys == false then
      cfg.keys = {}
    end
    cfg.keys[name] = keys
  end
  apply_jump_maps()
  return true
end

--- 设置/覆盖配置并立即生效；pairs 非法时回滚为默认配置
function M.setup(opts)
  opts = opts or {}
  merge(opts)

  local clean, err = sanitize(cfg.pairs)
  if not clean then
    merge() -- 回滚
    vim.notify("AutoPair.setup: " .. err, vim.log.levels.ERROR)
    return false
  end
  cfg.pairs = clean
  configured = true
  refresh_maps()
  return true
end

-- ============================================================
-- 用户命令
-- ============================================================

local function ensure_commands()
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
  vim.api.nvim_create_user_command("AutoPairJumpStart", function()
    M.jump_outer_start()
  end, { desc = "AutoPair: 跳转到配对外部开头" })
  vim.api.nvim_create_user_command("AutoPairJumpInside", function()
    M.jump_inner_middle()
  end, { desc = "AutoPair: 跳转到配对内部中间" })
  vim.api.nvim_create_user_command("AutoPairJumpEnd", function()
    M.jump_outer_end()
  end, { desc = "AutoPair: 跳转到配对外部结束" })
end

ensure_commands()

-- 首次 require 即按默认配置生效；之后调用 setup 可覆盖并重新生效
if not configured then
  M.setup()
end

return M
