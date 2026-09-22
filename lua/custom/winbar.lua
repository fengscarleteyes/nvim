-- lua/custom/winbar.lua
-- 结合 LSP 的 winbar（标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
-- 一条 winbar 只放“LSP 语义信息”（文件名、文件图标这一套 tabline 已经有了，这里不重复）：
--   左侧：面包屑（光标所在符号的层级路径）
--   右侧：LSP 客户端名  诊断计数
-- 示意（默认字形）：
--     󰅩 M 󰊕 outer 󰊕 inner                             󰒕 lua_ls ✘ 1 ▲ 2
--
-- 功能：
--   1. 面包屑：把 textDocument/documentSymbol 的结果按光标位置解析成符号链
--      （如 Class  Method  inner），每层带 SymbolKind 字形，层与层之间用分隔字形；
--      光标所在的最内层符号加粗显示（同底色、同色系，不做醒目提示）；
--      层级过深时只保留最内层 max_items 层并显示省略标记；
--   2. LSP 客户端：显示当前缓冲区已 attach 的客户端名，没有 LSP 时显示占位文案；
--   3. 诊断计数：按严重程度分类显示（配色与 custom/diagnostics.lua 保持一致），
--      无诊断时显示 ok 字形（可用 show_ok 关掉）；
--   4. 按文件类型隐藏（hide_filetypes：默认排除 mason / dashboard / neo-tree / help /
--      fzf / terminal 这些没有代码语义的界面缓冲区；实现上把全局 'winbar' 置空、改用
--      窗口局部值控制，M.restore() 会把全局值还原）；
--   5. 命令：:WinbarToggle :WinbarEnable :WinbarDisable :WinbarRefresh
--      键位默认不绑定（map_keys = false）：需要时 setup({ map_keys = true }) 会绑
--      <leader>wt（显示 / 隐藏）与 <leader>wr（重新取符号）。
--
-- 配色：自带配色（colors）独立于主题，切换主题后会自动重新应用；此模式下还会把
--   WinBar / WinBarNC 的背景对齐到底色（%= 撑出来的填充区由它们着色），保证整条 bar 底色一致。
--
-- 性能（winbar 的 %! 表达式每次重绘都要重新求值，所以渲染只读缓存）：
--   * documentSymbol 只在必要时异步请求（LspAttach / 文本改动 / 光标停顿 / 退出插入 /
--     保存 / 进入缓冲区且缓存过期时），并用 changedtick 校验丢弃过期响应；
--   * 光标移动只比较“光标所在符号是否变化”，变了才 :redrawstatus；
--   * 渲染整体 pcall 包裹：求值报错会让 Neovim 把 winbar 重置为默认值（:h stl-%!），
--     所以出错时只提示一次并返回空串，避免刷屏。
--
-- API：
--   require("custom.winbar").setup([opts])              合并配置并接管 winbar（幂等）
--   require("custom.winbar").render()                   生成 winbar 字符串（供 %! 表达式调用）
--   require("custom.winbar").refresh([bufnr], [force])  重新请求符号（异步，force 时先丢缓存）
--   require("custom.winbar").symbols([bufnr])           缓冲区缓存的符号节点（扁平，含 parent/depth）
--   require("custom.winbar").breadcrumb([win])          指定窗口光标所在的符号链（外层 -> 内层）
--   require("custom.winbar").apply()                    重新应用 'winbar'（含按文件类型隐藏）
--   require("custom.winbar").apply_highlights()         重新应用自带配色（切换主题后自动调用）
--   require("custom.winbar").enable() / disable() / toggle() / is_enabled()
--   require("custom.winbar").restore()                  还原本模块接管前的 'winbar' 并移除自动命令
--
-- 配置（M.setup(opts)）：
--   enabled             boolean  true        是否显示 winbar
--   map_keys            boolean  false       是否绑定默认键位（默认关，键位见下面 keys）
--   keys = {                                 lhs 设 false / "" 即不绑定
--     toggle  = "<leader>wt"                 显示 / 隐藏
--     refresh = "<leader>wr"                 重新取符号刷新面包屑
--   }
--   hide_filetypes      table    { "mason", "dashboard", "neo-tree", "help", "fzf", "terminal" }
--   max_items           number   3           面包屑最多显示几层（0 = 不显示面包屑，上限 20）
--   ellipsis            string   "…"         面包屑被截断时前面的省略标记（"" 关闭）
--   show_icons          boolean  true        面包屑显示 SymbolKind 字形
--   max_name_len        number   40          单个符号名的最大字符数（0 不截断）
--   show_client         boolean  true        右侧显示 LSP 客户端名
--   show_diagnostics    boolean  true        右侧显示诊断计数
--   show_ok             boolean  true        无诊断时显示 ok 字形
--   refresh_debounce_ms number   150         符号刷新的防抖时长（毫秒）
--   icons = {                                Nerd Font 字形（整体设 false 或单项设 "" 即不显示）
--     sep      = "<U+E0B1>", -- nf-pl-left_soft_divider（面包屑各层之间的分隔字形）
--                            （源码里这个私用区字形写成字节转义，避免编辑器把它丢掉）
--     client   = "󰒕",   -- LSP 客户端段
--     ok       = "󰄬",   -- nf-md-check（无诊断）
--   }
--   labels = {                              各段文案
--     no_client = "no LSP",                 没有 LSP 时的占位文案（"" 则不显示）
--   }
--   colors = {                              自带配色（独立于主题；整体设 false 则改用主题高亮组）
--     group    = "CustomWinbar",            高亮组名前缀（Crumb / Sep / Current / Client / Diag* 派生自它）
--     base     = { fg = "#565f89", bg = "#1a1b26" },               -- 底色：填充区与右侧状态区
--     crumb    = { fg = "#7aa2f7", bg = "#1a1b26" },               -- 面包屑（字形 + 名称）
--     current  = { fg = "#7aa2f7", bg = "#1a1b26", bold = true },  -- 光标所在的最内层符号（同底色，仅加粗）
--     diag     = {                                                 -- 诊断计数（与 custom/diagnostics.lua 一致）
--       error = { fg = "#FF6B6B", bg = "#1a1b26" },
--       warn  = { fg = "#FFD93D", bg = "#1a1b26" },
--       info  = { fg = "#6BCB77", bg = "#1a1b26" },
--       hint  = { fg = "#4D96FF", bg = "#1a1b26" },
--       ok    = { fg = "#6BCB77", bg = "#1a1b26" },
--     },
--     -- 其余项（sep / client）默认由上面几项派生，可单独覆盖
--   }
--   highlight           string   "WinBar"    colors = false 时的当前窗口高亮组
--   highlight_nc        string   "WinBarNC"  colors = false 时的非当前窗口高亮组
--
-- 示例：
--   require("custom.winbar").setup()                      -- 全默认（不绑键位）
--   require("custom.winbar").setup({                      -- 面包屑最多 2 层、右侧不显示客户端
--     max_items = 2,
--     show_client = false,
--   })
--   require("custom.winbar").setup({                      -- 关掉字形与自带配色，完全跟随主题
--     show_icons = false,
--     icons = false,
--     colors = false,
--   })
--   require("custom.winbar").setup({                      -- 只换光标所在符号的配色
--     colors = { current = { fg = "#9ece6a", bg = "#1a1b26", bold = true } },
--   })
--   require("custom.winbar").setup({ map_keys = true })    -- 顺便绑上 <leader>wt / <leader>wr
--   vim.keymap.set("n", "<F10>", function()               -- 或者自己绑一份
--     require("custom.winbar").refresh(nil, true)
--   end, { desc = "Winbar: refresh" })
local M = {}

--- LSP SymbolKind（数值见 :h lsp.SymbolKind）-> Nerd Font 字形
--- 取自 nvim-navic 的默认字形，可直接替换成自己喜欢的字形
local KIND_ICONS = {
  [1] = "󰈙", -- File
  [2] = "󰏗", -- Module
  [3] = "󰌗", -- Namespace
  [4] = "󰏗", -- Package
  [5] = "󰠱", -- Class
  [6] = "󰆧", -- Method
  [7] = "󰜢", -- Property
  [8] = "󰜢", -- Field
  [9] = "󰃀", -- Constructor
  [10] = "󰦨", -- Enum
  [11] = "󰜰", -- Interface
  [12] = "󰊕", -- Function
  [13] = "󰀫", -- Variable
  [14] = "󰏿", -- Constant
  [15] = "󰀬", -- String
  [16] = "󰎠", -- Number
  [17] = "󰨙", -- Boolean
  [18] = "󰅪", -- Array
  [19] = "󰅩", -- Object
  [20] = "󰌋", -- Key
  [21] = "󰟢", -- Null
  [22] = "󰦨", -- EnumMember
  [23] = "󰙅", -- Struct
  [24] = "󰃮", -- Event
  [25] = "󰆕", -- Operator
  [26] = "󰅲", -- TypeParameter
}

--- 诊断严重程度：显示顺序、配色键名、字形、默认前景色
--- （颜色与 custom/diagnostics.lua 的严重程度配色保持一致）
local SEVERITY = {
  { sev = vim.diagnostic.severity.ERROR, name = "Error", key = "error", icon = "✘", color = "#FF6B6B" },
  { sev = vim.diagnostic.severity.WARN, name = "Warn", key = "warn", icon = "▲", color = "#FFD93D" },
  { sev = vim.diagnostic.severity.INFO, name = "Info", key = "info", icon = "»", color = "#6BCB77" },
  { sev = vim.diagnostic.severity.HINT, name = "Hint", key = "hint", icon = "⚑", color = "#4D96FF" },
}

--- 默认配置
local DEFAULTS = {
  enabled = true,
  map_keys = false, -- 默认不绑键位，需要时 setup({ map_keys = true })
  keys = {
    toggle = "<leader>wt",
    refresh = "<leader>wr",
  },
  -- 这些 filetype 的缓冲区不显示 winbar（没有代码语义的界面缓冲区）
  hide_filetypes = { "mason", "dashboard", "neo-tree", "help", "fzf", "terminal" },
  max_items = 3, -- 面包屑最多显示几层；0 表示不显示面包屑
  ellipsis = "…", -- 面包屑被截断时前面的省略标记（"" 关闭）
  show_icons = true, -- 面包屑显示 SymbolKind 字形
  max_name_len = 40, -- 单个符号名的最大字符数（0 不截断）
  show_client = true, -- 右侧显示 LSP 客户端名
  show_diagnostics = true, -- 右侧显示诊断计数
  show_ok = true, -- 无诊断时显示 ok 字形
  refresh_debounce_ms = 150, -- 符号刷新防抖（毫秒）
  icons = { -- Nerd Font 字形；单项置 "" 去掉，整体设 false 全去掉
    -- 私用区字形写成字节转义：U+E0B1（换编辑器保存时不会被丢掉）
    sep = "", -- nf-pl-left_soft_divider：面包屑各层之间的分隔字形
    client = "󰒕", -- LSP 客户端
    ok = "󰄬", -- nf-md-check：无诊断
  },
  labels = {
    no_client = "no LSP", -- 没有 LSP 时的占位文案
  },
  colors = { -- 自带配色（独立于主题）；整体设 false 则改用 highlight / highlight_nc
    group = "CustomWinbar", -- 高亮组名前缀
    base = { fg = "#565f89", bg = "#1a1b26" }, -- 底色：填充区与右侧状态区
    crumb = { fg = "#7aa2f7", bg = "#1a1b26" }, -- 面包屑：亮色字
    current = { fg = "#7aa2f7", bg = "#1a1b26", bold = true }, -- 光标所在符号：同底色 / 同色系，仅加粗
    diag = { -- 诊断计数（与 custom/diagnostics.lua 的配色一致）
      error = { fg = "#FF6B6B", bg = "#1a1b26" },
      warn = { fg = "#FFD93D", bg = "#1a1b26" },
      info = { fg = "#6BCB77", bg = "#1a1b26" },
      hint = { fg = "#4D96FF", bg = "#1a1b26" },
      ok = { fg = "#6BCB77", bg = "#1a1b26" },
    },
  },
  highlight = "WinBar", -- colors = false 时的当前窗口高亮组
  highlight_nc = "WinBarNC", -- colors = false 时的非当前窗口高亮组
}

local cfg = vim.deepcopy(DEFAULTS)

local initialized = false -- setup() 是否已接管
local saved_winbar = nil -- 接管前的全局 'winbar'，供 M.restore() 还原
local render_failed = false -- 渲染出错只提示一次
local refresh_timer = nil -- 符号刷新用的防抖定时器（setup 时创建）
local commands_created = false -- 用户命令是否已注册
local keymaps_created = false -- 默认键位是否已绑定

--- 待重新请求符号的缓冲区集合（多个事件共用一个定时器做防抖）
local pending_refresh = {}
--- 符号缓存：[bufnr] = { tick = changedtick, nodes = 规范化后的节点 }
local cache = {}
--- 上次渲染时窗口所在符号的标识：[winid] = string（用于判断是否需要 :redrawstatus）
local last_symbol = {}

--- 'winbar' 的 %! 表达式：整条 bar 交给 M.render() 求值
local WINBAR_EXPR = '%!v:lua.require("custom.winbar").render()'

--- max_items 上限：避免一条 winbar 过长（也防止服务端返回异常数据时渲染开销过大）
local MAX_BREADCRUMB_ITEMS = 20

-- ============================================================
-- 通用工具
-- ============================================================

--- winbar/statusline 里 % 是特殊字符，字面量需要写成 %%
--- @param s string
--- @return string
local function escape_percent(s)
  return (s:gsub("%%", "%%%%"))
end

--- 清理符号名（换行/制表符会破坏 winbar）并按字符数截断
--- @param name string|nil
--- @param max_len integer 0 表示不截断
--- @return string
local function format_name(name, max_len)
  name = tostring(name or ""):gsub("%c", " ")
  if max_len and max_len > 0 and vim.fn.strchars(name) > max_len then
    -- 按字符数粗略截断（显示宽度差异可以忽略），末尾给出省略提示
    name = vim.fn.strcharpart(name, 0, max_len) .. "…"
  end
  return name
end

--- 取某个字形（"无字形" 返回 ""）
--- @param name string "sep" | "client" | "ok"
--- @return string
local function icon_of(name)
  local icons = cfg.icons
  if type(icons) ~= "table" then
    return ""
  end
  local icon = icons[name]
  return type(icon) == "string" and icon or ""
end

--- 取某段文案（nil / 非字符串一律按“不显示”处理）
--- @param name string "no_client"
--- @return string
local function label_of(name)
  local labels = cfg.labels
  if type(labels) ~= "table" then
    return ""
  end
  local value = labels[name]
  return type(value) == "string" and value or ""
end

--- 在字形与文本之间补一个空格（字形为空时只返回文本）
--- @param icon string
--- @param text string
--- @return string
local function with_icon(icon, text)
  if text == "" then
    return ""
  end
  return icon ~= "" and (icon .. " " .. text) or text
end

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

--- 窗口句柄归一化（nil / 0 表示当前窗口；无效窗口返回 nil）
--- @param win integer|nil
--- @return integer|nil
local function resolve_win(win)
  if win == nil or win == 0 then
    win = vim.api.nvim_get_current_win()
  end
  if vim.api.nvim_win_is_valid(win) then
    return win
  end
  return nil
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

--- 该缓冲区是否属于“不显示 winbar”的文件类型
--- @param buf integer
--- @return boolean
local function is_hidden(buf)
  local fts = cfg.hide_filetypes
  if type(fts) ~= "table" then
    return false
  end
  local ft = vim.bo[buf].filetype
  return ft ~= "" and vim.tbl_contains(fts, ft)
end

--- winbar 的显示标记：是否显示（含开关与按文件类型隐藏）
--- @param buf integer
--- @return boolean
local function should_show(buf)
  if not cfg.enabled then
    return false
  end
  return not is_hidden(buf)
end

-- ============================================================
-- 符号解析：documentSymbol -> 统一节点 -> 光标所在符号链
-- ============================================================

--- LSP 的 Range（0 基行列）-> 便于比较的扁平范围
--- @param r lsp.Range
--- @return table
local function flat_range(r)
  return { sl = r.start.line, sc = r.start.character, el = r["end"].line, ec = r["end"].character }
end

--- 范围“大小”（用于从多个包含光标的范围里挑出最内层）
--- @param r table
--- @return number
local function range_size(r)
  return (r.el - r.sl) * 1000000 + (r.ec - r.sc)
end

--- 光标是否落在范围内（LSP 的 end 是开区间）
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

--- a 是否完全包含 b（用于把平铺结果还原成层级）
--- @param a table
--- @param b table
--- @return boolean
local function range_contains(a, b)
  if a.sl > b.sl or a.el < b.el then
    return false
  end
  if a.sl == b.sl and a.sc > b.sc then
    return false
  end
  if a.el == b.el and a.ec < b.ec then
    return false
  end
  return true
end

--- 把 documentSymbol 的结果规范化成节点数组：
---   { name, kind, range, sel = { line, character }, parent = index|nil, depth = number }
--- 两种返回形态都兼容：
---   * DocumentSymbol   带 range / selectionRange / children（树形，父子关系直接可得）
---   * SymbolInformation 带 location（平铺，按范围包含关系补出父子关系）
--- @param raw table LSP 结果
--- @return table[] nodes 下标即 parent 指向的 index
local function normalize_symbols(raw)
  local nodes = {}

  if raw[1] and raw[1].range then
    local function walk(items, parent, depth)
      for _, item in ipairs(items) do
        if type(item.name) == "string" and item.range then
          nodes[#nodes + 1] = {
            name = item.name,
            kind = item.kind,
            range = flat_range(item.range),
            sel = item.selectionRange and {
              line = item.selectionRange.start.line,
              character = item.selectionRange.start.character,
            } or { line = item.range.start.line, character = item.range.start.character },
            parent = parent,
            depth = depth,
          }
          local index = #nodes
          if type(item.children) == "table" then
            walk(item.children, index, depth + 1)
          end
        end
      end
    end
    walk(raw, nil, 1)
    return nodes
  end

  -- 平铺结果：按范围从大到小处理，父节点就是“已处理过的、范围最小的包含者”
  for _, item in ipairs(raw) do
    if type(item.name) == "string" and item.location and item.location.range then
      nodes[#nodes + 1] = {
        name = item.name,
        kind = item.kind,
        range = flat_range(item.location.range),
        sel = { line = item.location.range.start.line, character = item.location.range.start.character },
      }
    end
  end
  table.sort(nodes, function(a, b)
    return range_size(a.range) > range_size(b.range)
  end)
  for i, node in ipairs(nodes) do
    local parent
    for j = i - 1, 1, -1 do
      if range_contains(nodes[j].range, node.range) then
        parent = j
        break
      end
    end
    node.parent = parent
    node.depth = parent and (nodes[parent].depth + 1) or 1
  end
  return nodes
end

--- 光标所在的符号链（外层 -> 内层）；光标不在任何符号内时返回 {}
--- @param nodes table[]
--- @param line integer 0 基行号
--- @param col integer 0 基列号
--- @return table[]
local function symbol_chain(nodes, line, col)
  local best, best_size
  for _, node in ipairs(nodes) do
    if in_range(node.range, line, col) then
      local size = range_size(node.range)
      -- 取“最深”的符号；同深度时取范围更小（更精确）的
      if
        not best
        or node.depth > best.depth
        or (node.depth == best.depth and (best_size == nil or size <= best_size))
      then
        best, best_size = node, size
      end
    end
  end
  if not best then
    return {}
  end

  local chain = {}
  local node = best
  local guard = 0 -- 防御性上限，异常数据也不至于死循环
  while node and guard < 64 do
    table.insert(chain, 1, node)
    node = node.parent and nodes[node.parent] or nil
    guard = guard + 1
  end
  return chain
end

-- ============================================================
-- 符号缓存与刷新（异步请求 textDocument/documentSymbol）
-- ============================================================

--- 指定窗口光标所在的符号链（窗口无效 / 尚无缓存时返回 {}）
--- @param win integer
--- @param buf integer
--- @return table[]
local function window_chain(win, buf)
  local entry = cache[buf]
  if not entry or type(entry.nodes) ~= "table" or #entry.nodes == 0 then
    return {}
  end
  local ok, pos = pcall(vim.api.nvim_win_get_cursor, win)
  if not ok or type(pos) ~= "table" then
    return {}
  end
  return symbol_chain(entry.nodes, pos[1] - 1, pos[2])
end

--- 光标所在符号的标识（同标识说明光标还在同一个符号里，就不必重绘）
--- @param win integer
--- @param buf integer
--- @return string
local function symbol_key(win, buf)
  local chain = window_chain(win, buf)
  local node = chain[#chain]
  if not node then
    return ""
  end
  local entry = cache[buf]
  return string.format("%s:%d:%s", tostring(entry and entry.tick or ""), node.range.sl, node.name)
end

--- 缓存是否与缓冲区当前 changedtick 一致（一致说明不必再发请求）
--- @param buf integer
--- @return boolean
local function cache_fresh(buf)
  local entry = cache[buf]
  return entry ~= nil and entry.tick == vim.api.nvim_buf_get_changedtick(buf)
end

--- 请求 documentSymbol（异步）：结果经 changedtick 校验后写入缓存，过期响应直接丢弃
--- @param buf integer
local function request_symbols(buf)
  if not resolve_buf(buf) then
    return
  end

  local entry = cache[buf]
  if not entry then
    entry = { tick = 0, nodes = {} }
    cache[buf] = entry
  end

  -- 记录本次请求对应的版本，回调里用它判断结果是否已经过期
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
    -- 没有 LSP：清空缓存，面包屑自然消失
    entry.nodes = {}
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
  local accepted = false -- 同一个 tick 只采纳第一个非空结果

  --- 回调：err 或空结果忽略；缓冲区已改动 / 请求已过期则丢弃
  local function on_result(err, result)
    if err or type(result) ~= "table" or #result == 0 then
      return
    end
    if not vim.api.nvim_buf_is_valid(buf) or cache[buf] ~= entry or entry.tick ~= tick then
      return
    end
    if vim.api.nvim_buf_get_changedtick(buf) ~= tick or accepted then
      return
    end
    accepted = true
    entry.nodes = normalize_symbols(result)
    -- 缓存换了：让“光标所在符号”的比较从头开始，并刷新一次 winbar
    last_symbol = {}
    pcall(vim.cmd, "redrawstatus")
  end

  for _, client in ipairs(clients) do
    -- 客户端可能刚好在初始化 / 退出，请求失败就跳过（下一次刷新会补上）
    pcall(client.request, client, "textDocument/documentSymbol", params, on_result, buf)
  end
end

--- 延时（防抖）重新请求符号：多个事件共用一个定时器，只在最后一次触发后真正请求
--- @param buf integer
--- @param delay integer|nil 毫秒；nil 用 cfg.refresh_debounce_ms
local function schedule_refresh(buf, delay)
  if not resolve_buf(buf) then
    return
  end
  if not refresh_timer then
    refresh_timer = vim.uv.new_timer()
  end
  pending_refresh[buf] = true
  refresh_timer:stop()
  -- uv.timer 回调不在主线程（不能直接调用 Neovim API），用 schedule_wrap 调度回主线程
  refresh_timer:start(
    delay or cfg.refresh_debounce_ms,
    0,
    vim.schedule_wrap(function()
      -- 取走当前批次并清空，避免处理期间的新请求被丢掉
      local bufs = pending_refresh
      pending_refresh = {}
      for b in pairs(bufs) do
        request_symbols(b)
      end
    end)
  )
end

--- 缓存过期（changedtick 变了）时才刷新
--- @param buf integer
local function refresh_if_stale(buf)
  if not resolve_buf(buf) then
    return
  end
  if not cache_fresh(buf) then
    schedule_refresh(buf)
  end
end

-- ============================================================
-- LSP 客户端
-- ============================================================

--- 当前缓冲区已 attach 的 LSP 客户端名（去重、排序；没有则返回 ""）
--- @param buf integer
--- @return string
local function client_names(buf)
  local names, seen = {}, {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local name = client.name or ""
    if name ~= "" and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return table.concat(names, " ")
end

-- ============================================================
-- 高亮与 winbar 选项
-- ============================================================

--- 应用自带配色（独立于主题；colors = false 时不做事）
--- 未显式配置的项由 base / crumb / current 推导，只覆盖一部分也能看
function M.apply_highlights()
  if type(cfg.colors) ~= "table" then
    return
  end
  local c = cfg.colors
  local base = c.group or DEFAULTS.colors.group
  local bg = c.base or DEFAULTS.colors.base
  local crumb = c.crumb or DEFAULTS.colors.crumb
  local current = c.current or DEFAULTS.colors.current
  local diag = c.diag or {}

  vim.api.nvim_set_hl(0, base, bg)
  vim.api.nvim_set_hl(0, base .. "Crumb", crumb)
  -- 面包屑层间分隔字形 / 截断省略标记：同底色 + 偏暗前景
  vim.api.nvim_set_hl(0, base .. "Sep", c.sep or { fg = "#3d59a1", bg = bg.bg })
  vim.api.nvim_set_hl(0, base .. "Current", current)
  vim.api.nvim_set_hl(0, base .. "Client", c.client or { fg = bg.fg, bg = bg.bg })
  -- 诊断：每个严重程度一套（默认前景色见 SEVERITY）
  for _, part in ipairs(SEVERITY) do
    vim.api.nvim_set_hl(0, base .. "Diag" .. part.name, diag[part.key] or { fg = part.color, bg = bg.bg })
  end
  vim.api.nvim_set_hl(0, base .. "DiagOk", diag.ok or { fg = "#6BCB77", bg = bg.bg })

  -- %= 撑出来的填充区由 WinBar / WinBarNC 决定着色（:h 'statusline'），
  -- 这里只把它们的背景对齐到底色，保证整条 bar 底色一致（前景保持不变）
  for _, name in ipairs({ "WinBar", "WinBarNC" }) do
    local origin = vim.api.nvim_get_hl(0, { name = name })
    vim.api.nvim_set_hl(0, name, { fg = origin.fg, bg = bg.bg })
  end
end

--- 本次渲染用到的高亮组名（colors = false 时跟随主题的 WinBar / WinBarNC / Diagnostic*）
--- @param in_focus boolean 该窗口是否为当前窗口
--- @return table
local function resolve_highlights(in_focus)
  if type(cfg.colors) ~= "table" then
    local hl = in_focus and cfg.highlight or cfg.highlight_nc
    local diag = {}
    for _, part in ipairs(SEVERITY) do
      diag[part.key] = "Diagnostic" .. part.name
    end
    diag.ok = "DiagnosticOk"
    return {
      base = hl,
      crumb = hl,
      sep = hl,
      current = hl,
      client = hl,
      diag = diag,
    }
  end

  local base = cfg.colors.group or DEFAULTS.colors.group
  local diag = {}
  for _, part in ipairs(SEVERITY) do
    diag[part.key] = base .. "Diag" .. part.name
  end
  diag.ok = base .. "DiagOk"
  return {
    base = base,
    crumb = base .. "Crumb",
    sep = base .. "Sep",
    current = base .. "Current",
    client = base .. "Client",
    diag = diag,
  }
end

--- 应用 'winbar'：全局值置空 + 逐个窗口设局部值
--- 为什么不用全局值？'winbar' 是 global-local 选项，把局部值设成 "" 等于“回到全局值”，
--- 所以要让某些窗口不显示 winbar，就只能让全局值为空、由局部值来打开。
--- （浮动窗口不使用全局值，见 :h 'winbar'，这里也不给它设局部值）
--- 接管前的全局值已保存在 saved_winbar，M.restore() 会还原。
function M.apply()
  if vim.go.winbar ~= "" then
    vim.go.winbar = ""
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      local want = should_show(vim.api.nvim_win_get_buf(win)) and WINBAR_EXPR or ""
      -- 读局部值来判断是否需要设置（读“有效值”会把全局值也算进来，判不准）
      if vim.api.nvim_get_option_value("winbar", { win = win, scope = "local" }) ~= want then
        vim.api.nvim_set_option_value("winbar", want, { win = win, scope = "local" })
      end
    end
  end
  pcall(vim.cmd, "redrawstatus")
end

-- ============================================================
-- 渲染：'winbar' 的 %! 表达式
-- ============================================================

--- 渲染主体：左侧 = 面包屑，右侧 = 客户端 / 诊断
--- @return string
local function render_impl()
  local win = render_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local hl = resolve_highlights(win == vim.api.nvim_get_current_win())

  -- 先累积片段，最后统一拼装：{ text = 已转义文本, hl = 高亮组 } 或 { raw = 控制序列 }
  local left, right = {}, {}
  local dst = left

  --- 原样输出控制序列（如 %= / %#分组#）
  local function push_raw(text)
    dst[#dst + 1] = { raw = text }
  end

  --- 输出一段文本（% 会被转义）
  local function push(text, group)
    if text == nil or text == "" then
      return
    end
    dst[#dst + 1] = { text = escape_percent(text), hl = group }
  end

  -- ---------- 左侧：面包屑 ----------
  local chain = {}
  if cfg.max_items > 0 then
    chain = window_chain(win, buf)
  end
  if #chain > 0 then
    -- 层数超过 max_items：只保留最内层 max_items 层，前面给一个省略标记
    local first = 1
    if #chain > cfg.max_items then
      first = #chain - cfg.max_items + 1
      if cfg.ellipsis ~= "" then
        push(cfg.ellipsis, hl.sep)
      end
    end

    for i = first, #chain do
      local node = chain[i]
      local is_current = i == #chain -- 最内层就是光标所在的符号
      local group = is_current and hl.current or hl.crumb
      local text =
        with_icon(cfg.show_icons and (KIND_ICONS[node.kind] or "") or "", format_name(node.name, cfg.max_name_len))

      -- 层与层之间用分隔字形（无字形时退化为一个空格）
      if i > first then
        if icon_of("sep") ~= "" then
          push(" ", hl.base)
          push(icon_of("sep"), hl.sep)
        end
      end
      push(" ", hl.base)
      push(text, group)
    end
  end

  -- ---------- 右侧：客户端 / 诊断 ----------
  dst = right
  local first_status = true

  --- 输出右侧的一段（段间用底色的空格分隔）
  local function push_status(text, group)
    if text == nil or text == "" then
      return
    end
    if not first_status then
      push(" ", hl.base)
    end
    first_status = false
    push(text, group)
  end

  -- LSP 客户端：没有 LSP 时显示占位文案
  if cfg.show_client then
    local names = client_names(buf)
    if names == "" then
      push_status(with_icon(icon_of("client"), label_of("no_client")), hl.client)
    else
      push_status(with_icon(icon_of("client"), names), hl.client)
    end
  end

  -- 诊断计数：按严重程度分类；没有诊断时显示 ok 字形
  if cfg.show_diagnostics then
    local counts = vim.diagnostic.count(buf)
    local found = false
    for _, part in ipairs(SEVERITY) do
      local count = counts[part.sev]
      if count and count > 0 then
        found = true
        push_status(part.icon .. " " .. count, hl.diag[part.key])
      end
    end
    if not found and cfg.show_ok then
      push_status(icon_of("ok"), hl.diag.ok)
    end
  end

  -- ---------- 拼装 ----------
  dst = left
  if #right > 0 then
    -- %= 让右侧靠右；填充区由 WinBar / WinBarNC 决定（见 M.apply_highlights()）
    push_raw("%=")
    for _, chunk in ipairs(right) do
      left[#left + 1] = chunk
    end
  end
  push_raw("%#" .. hl.base .. "#") -- 末尾空白也用底色

  local out = {}
  for _, chunk in ipairs(left) do
    if chunk.raw then
      out[#out + 1] = chunk.raw
    else
      out[#out + 1] = "%#" .. (chunk.hl or hl.base) .. "#" .. chunk.text
    end
  end
  return table.concat(out)
end

--- 生成 winbar 字符串（'winbar' 的 %! 表达式每次重绘都会调用它）
--- 求值出错会让 Neovim 把 'winbar' 重置为默认值（:h stl-%!），所以这里兜住异常：
--- 出错时只提示一次并返回空串，画面不会再刷屏
--- @return string
function M.render()
  local ok, result = pcall(render_impl)
  if ok then
    return result
  end
  if not render_failed then
    render_failed = true
    vim.schedule(function()
      vim.notify("[custom.winbar] 渲染失败: " .. tostring(result), vim.log.levels.ERROR)
    end)
  end
  return ""
end

-- ============================================================
-- 对外 API
-- ============================================================

--- 重新请求符号（异步）；bufnr 省略表示当前缓冲区
--- @param bufnr integer|nil
--- @param force boolean|nil 是否先丢弃现有缓存
function M.refresh(bufnr, force)
  local buf = resolve_buf(bufnr)
  if not buf then
    return
  end
  if force then
    cache[buf] = nil
    last_symbol = {}
  end
  schedule_refresh(buf, 0)
end

--- 指定缓冲区缓存的符号节点（扁平，含 name / kind / range / sel / parent / depth）
--- @param bufnr integer|nil
--- @return table[]
function M.symbols(bufnr)
  local buf = resolve_buf(bufnr)
  local entry = buf and cache[buf] or nil
  return (entry and entry.nodes) or {}
end

--- 指定窗口光标所在的符号链（外层 -> 内层）
--- @param win integer|nil
--- @return table[]
function M.breadcrumb(win)
  win = resolve_win(win)
  if not win then
    return {}
  end
  return window_chain(win, vim.api.nvim_win_get_buf(win))
end

--- winbar 是否显示
--- @return boolean
function M.is_enabled()
  return cfg.enabled
end

--- 显示 winbar
function M.enable()
  cfg.enabled = true
  M.apply()
end

--- 隐藏 winbar
function M.disable()
  cfg.enabled = false
  M.apply()
end

--- 显示 / 隐藏切换
function M.toggle()
  cfg.enabled = not cfg.enabled
  M.apply()
end

-- ============================================================
-- 自动命令 / 用户命令 / 键位
-- ============================================================

--- 注册自动命令（幂等）：刷新缓存 / 重绘 winbar / 按文件类型显示隐藏
local function ensure_autocmds()
  local augroup = vim.api.nvim_create_augroup("custom_winbar", { clear = true })

  -- 主题切换会清空自带配色，重新应用一次（同时把填充区底色再对齐一遍）
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    desc = "custom.winbar: 重新应用自带配色",
    callback = function()
      M.apply_highlights()
      pcall(vim.cmd, "redrawstatus")
    end,
  })

  -- 按文件类型显示 / 隐藏（新窗口、缓冲区进入窗口、filetype 变化都要重新算一遍）
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinNew" }, {
    group = augroup,
    desc = "custom.winbar: 按文件类型应用 winbar",
    callback = function()
      M.apply()
    end,
  })

  -- 文本变化：缓存已过期，触发一次防抖刷新（请求会带 changedtick 校验）
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = augroup,
    desc = "custom.winbar: 文本变化后刷新符号",
    callback = function(args)
      schedule_refresh(args.buf)
      pcall(vim.cmd, "redrawstatus")
    end,
  })

  -- 光标停顿 / 退出插入 / 保存 / 进入缓冲区：仅当缓存过期时才重新请求
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave", "BufWritePost", "BufEnter" }, {
    group = augroup,
    desc = "custom.winbar: 缓存过期时刷新符号",
    callback = function(args)
      refresh_if_stale(args.buf)
    end,
  })

  -- LSP attach / detach：立即重取符号（attach 之后才有 documentSymbol）
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    desc = "custom.winbar: LSP attach 后刷新符号",
    callback = function(args)
      M.refresh(args.buf, true)
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    group = augroup,
    desc = "custom.winbar: LSP detach 后刷新符号",
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
      local key = symbol_key(win, vim.api.nvim_win_get_buf(win))
      if last_symbol[win] ~= key then
        last_symbol[win] = key
        pcall(vim.cmd, "redrawstatus")
      end
    end,
  })

  -- 诊断变化：刷新右侧计数
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    desc = "custom.winbar: 诊断变化后重绘",
    callback = function()
      pcall(vim.cmd, "redrawstatus")
    end,
  })

  -- 清理：窗口 / 缓冲区关闭后不再保留相关状态
  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    desc = "custom.winbar: 清理关闭窗口的状态",
    callback = function(args)
      local win = tonumber(args.match)
      if win then
        last_symbol[win] = nil
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    desc = "custom.winbar: 清理已删除缓冲区的缓存",
    callback = function(args)
      cache[args.buf] = nil
      pending_refresh[args.buf] = nil
    end,
  })
end

--- 注册用户命令（幂等）
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true
  vim.api.nvim_create_user_command("WinbarToggle", function()
    M.toggle()
  end, { desc = "Winbar: 显示 / 隐藏" })
  vim.api.nvim_create_user_command("WinbarEnable", function()
    M.enable()
  end, { desc = "Winbar: 显示" })
  vim.api.nvim_create_user_command("WinbarDisable", function()
    M.disable()
  end, { desc = "Winbar: 隐藏" })
  vim.api.nvim_create_user_command("WinbarRefresh", function()
    M.refresh(nil, true)
  end, { desc = "Winbar: 重新取符号刷新面包屑" })
end

--- 绑定默认键位（lhs 为 false / "" 的项跳过；幂等）
local function ensure_keymaps()
  if keymaps_created then
    return
  end
  keymaps_created = true
  local keys = cfg.keys or {}
  local maps = {
    {
      lhs = keys.toggle,
      action = function()
        M.toggle()
      end,
      desc = "Winbar: 显示 / 隐藏",
    },
    {
      lhs = keys.refresh,
      action = function()
        M.refresh(nil, true)
      end,
      desc = "Winbar: 刷新面包屑",
    },
  }
  for _, map in ipairs(maps) do
    if type(map.lhs) == "string" and map.lhs ~= "" then
      vim.keymap.set("n", map.lhs, map.action, { desc = map.desc })
    end
  end
end

-- ============================================================
-- setup / restore
-- ============================================================

--- 合并配置并接管 winbar（幂等：重复调用只接管一次，但配置会即时刷新）
--- @param opts table|nil 见文件头部「配置」说明
--- @return table M
function M.setup(opts)
  opts = opts or {}
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts)
  -- 列表型 / 可整体关闭的配置要显式赋值：深合并会按下标合并列表，也会把 false 当成“缺省”
  if opts.hide_filetypes ~= nil then
    cfg.hide_filetypes = opts.hide_filetypes
  end
  if opts.colors == false then
    cfg.colors = false
  end
  if opts.icons == false then
    cfg.icons = false
  end
  if opts.labels == false then
    cfg.labels = false
  end
  -- 面包屑层数收敛：0 = 不显示面包屑，上限见 MAX_BREADCRUMB_ITEMS
  cfg.max_items = math.max(0, math.min(MAX_BREADCRUMB_ITEMS, tonumber(cfg.max_items) or DEFAULTS.max_items))

  -- 键位按当前配置补齐（ensure_keymaps 幂等，已绑过就不会重复）
  if cfg.map_keys then
    ensure_keymaps()
  end

  if initialized then
    -- 已经接管过：只刷新配色与 winbar 选项
    M.apply_highlights()
    M.apply()
    return M
  end
  initialized = true

  saved_winbar = vim.go.winbar -- 记住原值，便于 M.restore() 还原
  ensure_commands()
  M.apply_highlights()
  ensure_autocmds()
  M.apply()

  return M
end

--- 撤销接管：还原 'winbar'、移除自动命令与定时器
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
  if refresh_timer then
    refresh_timer:stop()
    refresh_timer:close()
    refresh_timer = nil
  end
  cache, last_symbol, pending_refresh = {}, {}, {}
  render_failed = false
  initialized = false
  pcall(vim.cmd, "redrawstatus")
end

return M
