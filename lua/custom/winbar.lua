-- lua/custom/winbar.lua
-- 窗口顶栏（winbar）面包屑（标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
-- 一条 winbar 只做一件事：显示光标所在符号的层级路径。
-- 文件名见 custom/tabline.lua，诊断数量见 custom/diagnostics.lua，这里都不放。
--   示意： cls > method > inner（最内层就是光标所在的符号）
--
-- 实现：
--   * 把 'winbar' 设成 %! 表达式（见 WINBAR_EXPR），每次重绘调用 M.render()；
--   * 符号来自 textDocument/documentSymbol：异步请求后按 changedtick 存进缓存，渲染时只在缓存里
--     按光标位置走一趟符号树（%! 每次重绘都要重新求值，所以渲染要轻、不发请求）；
--   * 缓存过期（文本改动 / 退出插入 / 保存 / 光标停顿 / 进入缓冲区 / LSP attach、detach）时重新请求，
--     文本改动走 150ms 防抖；过期的响应（changedtick 已变）直接丢弃；
--   * 服务端出错 / 没给结果时（例如 LuaLS 索引期间）把缓存标记成过期，下一次自动刷新会重试；
--   * 光标移动后只有“光标所在符号变了”才 :redrawstatus，同一个符号里移动不重绘；
--   * 树形结果（DocumentSymbol）直接用；旧式平铺结果（SymbolInformation）按范围包含关系补出层级；
--   * 过滤语句块类噪声符号（LuaLS 会把 if / for / return、匿名表也报成符号，见 NOISE_SYMBOL_NAMES），
--     被过滤的节点其子节点会提到上一层，所以 normalize > convert 这样的层级仍然保留；
--   * 配色跟随主题（WinBar / WinBarNC），不注册自带高亮组；
--   * 没有符号时返回空串；
--   * 渲染整体 pcall 包裹：求值报错会让 Neovim 把 winbar 重置为默认值（:h stl-%!），
--     所以出错时只提示一次并返回空串，避免刷屏。
--
-- 这些 filetype 不显示 winbar（没有代码语义的界面缓冲区）：
--   mason / dashboard / neo-tree / help / fzf / terminal / custom_diag（诊断面板）。
--   实现上把全局 'winbar' 置空、改用窗口局部值控制，M.restore() 会把全局值还原。
--
-- 没有配置项：要改行为（层数上限、分隔符、隐藏的 filetype …）直接改下面的常量。
--
-- API：
--   require("custom.winbar").setup()                   接管 winbar（幂等）
--   require("custom.winbar").render()                  生成 winbar 字符串（供 %! 表达式调用）
--   require("custom.winbar").refresh([bufnr], [force]) 重新请求符号（异步，force 时先丢缓存）
--   require("custom.winbar").apply()                   重新应用 'winbar'（含按文件类型隐藏）
--   require("custom.winbar").toggle()                  显示 / 隐藏
--   require("custom.winbar").restore()                 还原本模块接管前的 'winbar' 并移除自动命令
--
-- 命令：:WinbarToggle（显示 / 隐藏）:WinbarRefresh（重新取符号刷新面包屑）
local M = {}

--- 面包屑最多显示几层：超出时只保留最内层 MAX_ITEMS 层，前面加 ELLIPSIS
local MAX_ITEMS = 3
local ELLIPSIS = "…"
--- 层与层之间的分隔符
local SEPARATOR = " > "
--- 不显示 winbar 的 filetype（没有代码语义的界面缓冲区）
local NO_WINBAR_FILETYPES = {
  mason = true,
  dashboard = true,
  ["neo-tree"] = true,
  help = true,
  fzf = true,
  terminal = true,
  custom_diag = true, -- custom.diagnostics 的底部 / 右侧面板
}
--- 语句块 / 占位符类符号名（LuaLS 会把 if / for / return、匿名表也报成符号）：
--- 它们不是可跳转的位置，放进面包屑只会制造 "normalize > if > convert" 这种噪声，
--- 所以自身不显示、把子节点提到上一层（见 normalize）
local NOISE_SYMBOL_NAMES = {
  ["if"] = true,
  ["elseif"] = true,
  ["else"] = true,
  ["for"] = true,
  ["while"] = true,
  ["repeat"] = true,
  ["do"] = true,
  ["return"] = true,
  ["_"] = true,
}
--- 符号刷新防抖时长（毫秒）
local DEBOUNCE_MS = 150

--- 'winbar' 的 %! 表达式：整条 bar 交给 M.render() 求值
local WINBAR_EXPR = '%!v:lua.require("custom.winbar").render()'

--- 是否显示（:WinbarToggle 切换）/ 是否已接管 / 接管前的全局 'winbar'（供 M.restore() 还原）
local enabled = true
local initialized = false
local saved_winbar = nil
local commands_created = false
--- 渲染出错只提示一次
local render_failed = false

--- 缓存版本哨兵：与任何 changedtick 都不相等（changedtick 从 1 起）。
--- 请求失败 / 无结果时用它把缓存标记成“过期”，下一次自动刷新会重新请求（见 on_result）
local STALE_TICK = -1

--- 符号缓存：[bufnr] = { tick = 请求时的 changedtick, tree = { name, range, children } 树 }
local cache = {}
--- 防抖计数：[bufnr] = number（防抖窗口内只有最后一次调度真正发请求）
local pending = {}
--- 上次渲染出的面包屑文本：[winid] = string（光标移动后据此判断是否需要重绘）
local rendered = {}

-- ============================================================
-- 通用工具
-- ============================================================

--- 正在绘制的窗口：%! 表达式是在“当前窗口”上下文里求值的（:h stl-%!），
--- 目标窗口句柄放在 g:statusline_winid 里
--- @return integer
local function render_win()
  local win = tonumber(vim.g.statusline_winid)
  if win and vim.api.nvim_win_is_valid(win) then
    return win
  end
  return vim.api.nvim_get_current_win()
end

--- 缓冲区句柄归一化（nil / 0 表示当前缓冲区；无效缓冲区返回 nil）
--- @param bufnr integer|nil
--- @return integer|nil
local function resolve_buf(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    return bufnr
  end
  return nil
end

--- 该缓冲区是否显示 winbar（显示开关 + filetype 过滤）
--- @param buf integer
--- @return boolean
local function should_show(buf)
  if not enabled then
    return false
  end
  return not NO_WINBAR_FILETYPES[vim.bo[buf].filetype]
end

--- 清理符号名（换行 / 制表符会破坏 winbar）
--- @param name string
--- @return string
local function clean_name(name)
  return (tostring(name):gsub("%c", " "))
end

-- ============================================================
-- 符号解析：documentSymbol -> 符号树 -> 光标所在符号的层级路径
-- ============================================================

--- LSP 的 Range（0 基行列）-> 便于比较的扁平范围
--- @param r lsp.Range
--- @return table
local function flat_range(r)
  return { sl = r.start.line, sc = r.start.character, el = r["end"].line, ec = r["end"].character }
end

--- 范围“大小”（排序用，只求可比、不求物理意义）
--- @param r table
--- @return number
local function range_size(r)
  return (r.el - r.sl) * 1000000 + (r.ec - r.sc)
end

--- 位置是否落在范围内（LSP 的 end 是开区间）
--- @param r table
--- @param line integer 0 基行号
--- @param col integer 0 基列号
--- @return boolean
local function in_range(r, line, col)
  if line < r.sl or line > r.el then
    return false
  end
  if line == r.sl and col < r.sc then
    return false
  end
  if line == r.el and col > r.ec then
    return false
  end
  return true
end

--- a 的范围是否包含 b（把平铺结果补成层级时用）
--- @param a table
--- @param b table
--- @return boolean
local function contains(a, b)
  local starts_before = a.sl < b.sl or (a.sl == b.sl and a.sc <= b.sc)
  local ends_after = a.el > b.el or (a.el == b.el and a.ec >= b.ec)
  return starts_before and ends_after
end

--- 是否噪声符号：匿名（名字只有空白）或语句块类（见 NOISE_SYMBOL_NAMES）
--- @param name string
--- @return boolean
local function is_noise(name)
  return NOISE_SYMBOL_NAMES[name] or name:find("^%s*$") ~= nil
end

--- 把 documentSymbol 的结果统一成符号树：{ name, range = 扁平范围, children = { ... } }
--- 两种返回形态都兼容：
---   * DocumentSymbol    带 range / children（树形，父子关系直接可得）
---   * SymbolInformation 带 location（旧式平铺，按范围包含关系补出父子）
--- @param raw table LSP 结果
--- @return table[] 顶层节点
local function normalize(raw)
  if type(raw[1]) == "table" and raw[1].range then
    --- 深度优先转换：顺手丢掉没有 name / range 的异常项；噪声节点自身丢掉、子节点提到上一层
    local function convert(items, nodes)
      for _, item in ipairs(items) do
        if type(item.name) == "string" and type(item.range) == "table" then
          local children = {}
          if type(item.children) == "table" then
            convert(item.children, children)
          end
          if is_noise(item.name) then
            for _, child in ipairs(children) do
              nodes[#nodes + 1] = child
            end
          else
            nodes[#nodes + 1] = { name = item.name, range = flat_range(item.range), children = children }
          end
        end
      end
    end
    local tree = {}
    convert(raw, tree)
    return tree
  end

  -- 平铺：丢掉噪声节点后按范围从大到小处理，父节点就是“已处理过的、包含它的范围最小的节点”
  local nodes = {}
  for _, item in ipairs(raw) do
    if type(item.name) == "string" and item.location and item.location.range and not is_noise(item.name) then
      nodes[#nodes + 1] = { name = item.name, range = flat_range(item.location.range), children = {} }
    end
  end
  table.sort(nodes, function(a, b)
    return range_size(a.range) > range_size(b.range)
  end)
  local roots = {}
  for i, node in ipairs(nodes) do
    local parent
    for j = i - 1, 1, -1 do
      if contains(nodes[j].range, node.range) then
        parent = nodes[j]
        break
      end
    end
    if parent then
      parent.children[#parent.children + 1] = node
    else
      roots[#roots + 1] = node
    end
  end
  return roots
end

--- 光标位置在符号树里的层级路径（外层 -> 内层）
--- @param tree table[]
--- @param line integer 0 基行号
--- @param col integer 0 基列号
--- @param names string[] 累积结果
--- @return string[]
local function pick_chain(tree, line, col, names)
  for _, node in ipairs(tree) do
    if in_range(node.range, line, col) then
      names[#names + 1] = node.name
      -- 同一层里最多只有一个符号包含光标，直接往下一层找
      return pick_chain(node.children, line, col, names)
    end
  end
  return names
end

-- ============================================================
-- 符号缓存与刷新（异步请求 textDocument/documentSymbol）
-- ============================================================

--- 请求符号（异步）：结果经 changedtick 校验后写入缓存，过期响应直接丢弃
--- @param buf integer
local function request_symbols(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local entry = cache[buf] or { tick = STALE_TICK, tree = {} }
  cache[buf] = entry
  -- 本次请求对应的版本：回调里用它判断结果是否已经过期
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  entry.tick = tick

  -- 只问支持 documentSymbol 的客户端（同一缓冲区可能 attach 了多个）
  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if client:supports_method("textDocument/documentSymbol", buf) then
      clients[#clients + 1] = client
    end
  end
  if #clients == 0 then
    entry.tree = {} -- 没有 LSP：清空缓存，面包屑自然消失
    return
  end

  --- 回调：缓冲区已改动 / 已有更新的请求 -> 丢弃；
  --- 出错 / 没有结果（服务端还在索引等）-> 把缓存标记成过期，等下一次自动刷新重试；
  --- 空结果（该文件确实没有符号）-> 当有效结果接受，避免反复请求
  local function on_result(err, result)
    if not vim.api.nvim_buf_is_valid(buf) or cache[buf] ~= entry or entry.tick ~= tick then
      return
    end
    if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
      return
    end
    if err ~= nil or type(result) ~= "table" then
      entry.tick = STALE_TICK
      return
    end
    entry.tree = normalize(result)
    rendered = {} -- 缓存换了：让“光标所在符号”的比较从头开始
    pcall(vim.cmd, "redrawstatus")
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
  for _, client in ipairs(clients) do
    -- 客户端可能刚好在初始化 / 退出，请求失败就跳过（下一次刷新会补上）
    pcall(client.request, client, "textDocument/documentSymbol", params, on_result, buf)
  end
end

--- 防抖刷新：防抖窗口内对同一缓冲区的多次请求只保留最后一次
--- @param buf integer
--- @param delay integer|nil 毫秒；nil 用 DEBOUNCE_MS
local function schedule_refresh(buf, delay)
  pending[buf] = (pending[buf] or 0) + 1
  local gen = pending[buf]
  vim.defer_fn(function()
    if pending[buf] == gen then
      pending[buf] = nil
      request_symbols(buf)
    end
  end, delay or DEBOUNCE_MS)
end

--- 缓存与缓冲区当前 changedtick 不一致（过期）时才刷新
--- @param buf integer
local function refresh_if_stale(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local entry = cache[buf]
  if not entry or entry.tick ~= vim.api.nvim_buf_get_changedtick(buf) then
    schedule_refresh(buf)
  end
end

-- ============================================================
-- 渲染：'winbar' 的 %! 表达式
-- ============================================================

--- 指定窗口光标所在符号的层级路径文本（没有缓存 / 光标不在任何符号内时返回 ""）
--- @param win integer
--- @return string
local function crumb_text(win)
  local entry = cache[vim.api.nvim_win_get_buf(win)]
  if not entry or #entry.tree == 0 then
    return ""
  end

  local pos = vim.api.nvim_win_get_cursor(win)
  local names = pick_chain(entry.tree, pos[1] - 1, pos[2], {})
  if #names == 0 then
    return ""
  end

  -- 层数过多：只保留最内层 MAX_ITEMS 层，前面给一个省略标记
  local first = math.max(1, #names - MAX_ITEMS + 1)
  local parts = {}
  if first > 1 then
    parts[1] = ELLIPSIS
  end
  for i = first, #names do
    parts[#parts + 1] = clean_name(names[i])
  end
  return " " .. table.concat(parts, SEPARATOR)
end

--- 生成 winbar 字符串（'winbar' 的 %! 表达式每次重绘都会调用它）
--- 求值出错会让 Neovim 把 'winbar' 重置为默认值（:h stl-%!），所以这里兜住异常：
--- 出错时只提示一次并返回空串，画面不会再刷屏
--- @return string
function M.render()
  local win = render_win()
  local ok, text = pcall(crumb_text, win)
  if not ok then
    if not render_failed then
      render_failed = true
      vim.schedule(function()
        vim.notify("[custom.winbar] 渲染失败: " .. tostring(text), vim.log.levels.ERROR)
      end)
    end
    return ""
  end
  rendered[win] = text
  return (text:gsub("%%", "%%%%")) -- winbar 里 % 是特殊字符，字面量要写成 %%
end

-- ============================================================
-- 对外 API
-- ============================================================

--- 重新应用 'winbar'：全局值置空 + 逐个窗口设局部值
--- 'winbar' 是 global-local 选项：局部值设成 "" 等于“回到全局值”，所以要让某些窗口不显示 winbar，
--- 只能让全局值为空、由局部值来打开（浮动窗口不使用全局值，这里也不给它设局部值，见 :h 'winbar'）
function M.apply()
  if vim.go.winbar ~= "" then
    vim.go.winbar = ""
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      local want = should_show(vim.api.nvim_win_get_buf(win)) and WINBAR_EXPR or ""
      -- 读局部值判断是否需要设置：读“有效值”会把全局值也算进来，判不准
      if vim.api.nvim_get_option_value("winbar", { win = win, scope = "local" }) ~= want then
        vim.api.nvim_set_option_value("winbar", want, { win = win, scope = "local" })
      end
    end
  end
  pcall(vim.cmd, "redrawstatus")
end

--- 重新请求符号（异步）；bufnr 省略表示当前缓冲区
--- @param bufnr integer|nil
--- @param force boolean|nil 是否先丢弃现有缓存
function M.refresh(bufnr, force)
  bufnr = resolve_buf(bufnr)
  if not bufnr then
    return
  end
  if force then
    cache[bufnr] = nil
    rendered = {}
  end
  schedule_refresh(bufnr, 0)
end

--- 显示 / 隐藏 winbar 切换
function M.toggle()
  enabled = not enabled
  M.apply()
end

-- ============================================================
-- 命令 / 自动命令 / setup / restore
-- ============================================================

--- 注册用户命令（幂等）
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true
  vim.api.nvim_create_user_command("WinbarToggle", M.toggle, { desc = "Winbar: 显示 / 隐藏" })
  vim.api.nvim_create_user_command("WinbarRefresh", function()
    M.refresh(nil, true)
  end, { desc = "Winbar: 重新取符号刷新面包屑" })
end

--- 注册自动命令（幂等）：刷新缓存 / 重绘 winbar / 按文件类型显示隐藏
local function ensure_autocmds()
  local augroup = vim.api.nvim_create_augroup("custom_winbar", { clear = true })

  -- 新窗口 / 缓冲区进入窗口 / filetype 变化：重新算一遍该窗口是否显示 winbar
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinNew" }, {
    group = augroup,
    desc = "custom.winbar: 按文件类型应用 winbar",
    callback = M.apply,
  })

  -- 文本变化 / 退出插入 / 保存：缓存必然过期，防抖重新请求
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufWritePost" }, {
    group = augroup,
    desc = "custom.winbar: 文本变化后刷新符号",
    callback = function(args)
      refresh_if_stale(args.buf)
      pcall(vim.cmd, "redrawstatus")
    end,
  })

  -- 光标停顿 / 进入缓冲区：仅当缓存过期时才重新请求（补上被丢弃的过期响应）
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter" }, {
    group = augroup,
    desc = "custom.winbar: 缓存过期时刷新符号",
    callback = function(args)
      refresh_if_stale(args.buf)
    end,
  })

  -- LSP attach / detach（attach 之后才有 documentSymbol）：立即重取符号
  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    group = augroup,
    desc = "custom.winbar: LSP attach / detach 后刷新符号",
    callback = function(args)
      M.refresh(args.buf, true)
    end,
  })

  -- 光标移动：只有“光标所在符号变了”才重绘（同一个符号里移动不必重绘）
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    desc = "custom.winbar: 光标跨符号时重绘",
    callback = function()
      local win = vim.api.nvim_get_current_win()
      local ok, text = pcall(crumb_text, win)
      if ok and rendered[win] ~= text then
        pcall(vim.cmd, "redrawstatus")
      end
    end,
  })

  -- 清理：窗口 / 缓冲区关闭后不再保留相关状态
  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    desc = "custom.winbar: 清理已关闭窗口的状态",
    callback = function(args)
      rendered[tonumber(args.match)] = nil
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    desc = "custom.winbar: 清理已删除缓冲区的缓存",
    callback = function(args)
      cache[args.buf] = nil
      pending[args.buf] = nil
    end,
  })
end

--- 接管 winbar（幂等：重复调用只接管一次）
--- @return table M
function M.setup()
  if initialized then
    M.apply()
    return M
  end
  initialized = true

  saved_winbar = vim.go.winbar -- 记住原值，便于 M.restore() 还原
  ensure_commands()
  ensure_autocmds()
  M.apply()

  return M
end

--- 撤销接管：还原 'winbar'、移除自动命令
--- 注意：本模块接管期间给窗口设过局部的 'winbar'，撤销时会清空（原值只还原全局项）
function M.restore()
  if saved_winbar ~= nil then
    vim.go.winbar = saved_winbar
    saved_winbar = nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      pcall(vim.api.nvim_set_option_value, "winbar", "", { win = win, scope = "local" })
    end
  end
  pcall(vim.api.nvim_del_augroup_by_name, "custom_winbar")
  cache, pending, rendered = {}, {}, {}
  render_failed = false
  initialized = false
  pcall(vim.cmd, "redrawstatus")
end

return M
