-- lua/custom/autopair.lua
-- 自动补全成对字符（Auto Pair；标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
-- 只做三件事：
--   1. 配对插入：输入 ( [ { " ' ` * 时补全右半并让光标停在中间；
--   2. 智能闭合：输入闭字符且右侧正好是它时跳过（不重复插入；引号类右侧已有同字符同样跳过）；
--   3. 智能退格：光标停在空对 () / "" 中间时，一次删掉整对。
-- 引号类（" ' ` * 首尾同字符）带“单词边不成对”启发：输入 it's 的撇号只插一个引号。
--
-- 命令：:AutoPairToggle（启用 / 禁用）:AutoPairEnable :AutoPairDisable
--
-- API：
--   require("custom.autopair").setup([opts])   合并配置、注册插入映射与命令（可重复调用）
--   require("custom.autopair").enable() / disable() / toggle()
--
-- 配置（M.setup(opts)）：
--   enabled         boolean  true  是否启用（禁用会移除全部插入映射）
--   pairs = {                      配对表：以默认表为底逐项覆盖；某项设 false 表示不要这一对
--     ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'", ["`"] = "`", ["*"] = "*",
--   }
--   smart_quotes    boolean  true  引号类仅在两侧都不是单词字符时成对
--   skip_closing    boolean  true  输入闭字符且右侧正好是它时跳过
--   bs_delete_pair  boolean  true  空对之间退格一次删整对
--
-- 示例：
--   require("custom.autopair").setup()                              -- 全默认
--   require("custom.autopair").setup({ pairs = { ["<"] = ">" } })   -- 再加一对尖括号
--   require("custom.autopair").setup({ pairs = { ["'"] = false } }) -- 不要单引号这一对
--
-- 单独关掉某个 buffer（全局开关仍可用）：vim.b.autopair_enabled = false
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
  smart_quotes = true, -- 首尾同字符的配对（引号类）的“单词边不成对”启发式
  skip_closing = true, -- 闭字符右侧正好是它时跳过
  bs_delete_pair = true, -- 空对之间退格一次删整对
}

local cfg = vim.deepcopy(DEFAULTS)
--- 我们注册过的插入模式按键（禁用 / 重建映射时按它卸载）
local owned_insert = {}
local commands_created = false

-- ============================================================
-- 通用工具
-- ============================================================

--- 光标上下文：插入点左侧 / 右侧的字符（行首行尾时为 ""）
--- @return { before: string, under: string }
local function get_ctx()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1] - 1, cur[2]
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
  -- col 是 0 基，同时正好是左侧字符的 1 基下标
  return {
    before = string.sub(line, col, col),
    under = string.sub(line, col + 1, col + 1),
  }
end

--- 是否单词字符（ASCII 字母 / 数字 / 下划线）
--- @param ch string
--- @return boolean
local function is_word_char(ch)
  return ch ~= "" and ch:match("[%w_]") ~= nil
end

--- 当前是否执行配对动作（全局开关 + 该 buffer 未被单独关闭）
--- @return boolean
local function active()
  return cfg.enabled and vim.b.autopair_enabled ~= false
end

--- 是否为合法配对：开 / 闭都必须是单个字符（多字节字符也算 1 个）
--- @param open any
--- @param close any
--- @return boolean
local function is_pair(open, close)
  if type(open) ~= "string" or type(close) ~= "string" then
    return false
  end
  return vim.fn.strchars(open) == 1 and vim.fn.strchars(close) == 1
end

-- ============================================================
-- 插入模式处理器（由 <expr> 映射调用，返回要“打出”的键序列）
-- 返回值里的 "<Left>" "<Right>" "<BS>" "<Del>" 会被当作按键处理；普通字符直接插入，
-- 且不会再触发自身映射，所以“不配对”时把字符原样返回即可
-- ============================================================

--- 输入开字符（如 '('、'"'）
--- @param ch string
--- @return string
local function ins_open(ch)
  if not active() then
    return ch
  end
  local close = cfg.pairs[ch]
  if not close then
    return ch
  end

  if ch == close then
    local ctx = get_ctx()
    -- 右侧正好是同字符：那是已存在的闭号，跳过而不是再插一个
    if cfg.skip_closing and ctx.under == ch then
      return "<Right>"
    end
    -- 两侧任一侧是单词字符（it's / a'b 的撇号）：只插一个
    if cfg.smart_quotes and (is_word_char(ctx.before) or is_word_char(ctx.under)) then
      return ch
    end
    return ch .. ch .. "<Left>"
  end

  -- 常规开括号：补全并回退一步，光标停在中间
  return ch .. close .. "<Left>"
end

--- 输入闭字符（如 ')'）
--- @param ch string
--- @return string
local function ins_close(ch)
  if not active() then
    return ch
  end
  -- 右侧正好是它：跳过（避免打出 "))"）
  if cfg.skip_closing and get_ctx().under == ch then
    return "<Right>"
  end
  return ch
end

--- 输入退格
--- @return string
local function ins_backspace()
  if not active() or not cfg.bs_delete_pair then
    return "<BS>"
  end
  local ctx = get_ctx()
  -- 左侧是开字符、右侧正好是它的闭字符 => 光标在空对中间，一次删整对
  local close = cfg.pairs[ctx.before]
  if close and close == ctx.under then
    return "<BS><Del>"
  end
  return "<BS>"
end

-- ============================================================
-- 插入模式映射的注册 / 卸载
-- ============================================================

--- 卸载我们注册过的插入模式映射（禁用 / 重建映射时调用）
local function clear_insert_maps()
  for _, lhs in ipairs(owned_insert) do
    pcall(vim.keymap.del, "i", lhs)
  end
  owned_insert = {}
end

--- 注册插入模式映射（只在启用时调用；内部先 clear，重复调用不会残留）
local function apply_insert_maps()
  clear_insert_maps()
  for open, close in pairs(cfg.pairs) do
    -- 引号类 open == close：同一个处理器负责 配对 / 跳过 / 只插单个
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
  vim.keymap.set("i", "<BS>", ins_backspace, { expr = true }) -- 空对退格
  owned_insert[#owned_insert + 1] = "<BS>"
end

--- 按开关状态刷新映射
local function refresh_maps()
  if cfg.enabled then
    apply_insert_maps()
  else
    clear_insert_maps()
  end
end

-- ============================================================
-- 开关 / 用户命令 / setup
-- ============================================================

--- 启用自动配对（重新注册插入映射）
function M.enable()
  if cfg.enabled then
    return
  end
  cfg.enabled = true
  apply_insert_maps()
  vim.notify("AutoPair: 已启用", vim.log.levels.INFO)
end

--- 禁用自动配对（移除全部插入映射，不影响其它插件）
function M.disable()
  if not cfg.enabled then
    return
  end
  cfg.enabled = false
  clear_insert_maps()
  vim.notify("AutoPair: 已禁用", vim.log.levels.INFO)
end

--- 启用 / 禁用切换
function M.toggle()
  if cfg.enabled then
    M.disable()
  else
    M.enable()
  end
end

--- 注册用户命令（幂等）
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true
  vim.api.nvim_create_user_command("AutoPairToggle", M.toggle, { desc = "AutoPair: 启用 / 禁用" })
  vim.api.nvim_create_user_command("AutoPairEnable", M.enable, { desc = "AutoPair: 启用" })
  vim.api.nvim_create_user_command("AutoPairDisable", M.disable, { desc = "AutoPair: 禁用" })
end

--- 合并配置并立即生效（可重复调用，映射会重建）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  -- pairs 传了非表值（如 pairs = false）：退回默认配对（旧实现同样不报错）
  if type(cfg.pairs) ~= "table" then
    cfg.pairs = vim.deepcopy(DEFAULTS.pairs)
  end
  -- pairs：值为 false 表示“不要这一对”；顺手丢掉不合法的项（非单字符）
  for open, close in pairs(cfg.pairs) do
    if close == false then
      cfg.pairs[open] = nil
    elseif not is_pair(open, close) then
      cfg.pairs[open] = nil
      vim.notify(string.format("AutoPair: 忽略非法配对项 %s", vim.inspect({ open, close })), vim.log.levels.WARN)
    end
  end
  ensure_commands()
  refresh_maps()
  return M
end

return M
