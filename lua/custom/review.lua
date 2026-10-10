-- ============================================================
-- 审查（vibe coding review）工作流：改动文件面板 + 并排 diff
-- ------------------------------------------------------------
-- 定位：diffview 的自研替代（纯原生 API + git CLI，不依赖 gitsigns /
-- diffview / fzf），把「刷新磁盘 -> 看改动范围 -> 逐块审查 -> 处置」串成
-- 一条命令驱动的工作流。gitsigns 保留（行内标记 / word_diff / blame）。
--
-- 工作流：
--   :Review          刷新全部缓冲区的磁盘内容（checktime），打开改动文件面板
--   :ReviewFiles     打开 / 聚焦改动文件面板
--   :ReviewDiff      打开当前文件（或面板选中项）的并排 diff
--   :ReviewClose     关闭 diff 布局与面板
--   :ReviewToggle    开关文件面板
--   :ReviewStage     暂存当前文件（git add）
--   :ReviewReset     丢弃当前文件的工作区改动（git checkout --，带确认）
--   :ReviewStatus    一行进度：改动文件数 / 当前文件第几个
--   :ReviewRefresh   重新读取 git status 刷新列表
--
-- diff 布局：工作区 buffer 与基线 buffer（git show HEAD:path；未跟踪 /
-- 已删除文件用空基线）`:vertical rightbelow split` 并排 + :diffthis。
-- 逐块审查用内置 ]c / [c 跳 diff 变化、foldmethod=diff 折叠未变区。
--
-- 默认不绑键位（沉浸式审查，不被键位打断）：map_keys = true 才绑定
-- cfg.keys 里的键；面板内部键位除外（j / k 移动、<CR> 打开、q / <Esc>
-- 关闭，是面板交互的一部分，进入面板即生效，不受 map_keys 控制）。
--
-- 面板文件类型 review_panel：已加入 custom.winbar 的 NO_WINBAR_FILETYPES
-- 与 custom.diagnostics 的 disable_filetypes，不画面包屑、不弹诊断浮窗。
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   panel_width  number  50       面板内容宽度（列）
--   panel_height number  18       面板内容最大高度（行，实际按条目数收缩）
--   border       string  "single" 面板边框（none / single / double / rounded / solid）
--   position     string  "right"  面板位置（right / left），垂直居中
--   map_keys     boolean false    是否绑定全局键位（默认不绑）
--   keys         table   见下     map_keys = true 时使用的键位
--     files   "<leader>rv"   打开 / 聚焦面板
--     diff    "<leader>rd"   打开当前文件 diff
--     close   "<leader>rc"   关闭 diff 与面板
--     toggle  "<leader>rt"   开关面板
--     status  "<leader>rs"   审查进度
--
-- API：
--   require("custom.review").setup([opts])  合并配置并生效（幂等）
--   require("custom.review").files()        打开 / 聚焦文件面板
--   require("custom.review").diff()         打开当前文件（或面板选中项）diff
--   require("custom.review").close()        关闭 diff 布局与面板
--   require("custom.review").toggle()       开关面板
--   require("custom.review").status()       进度提示
--   require("custom.review").refresh()      刷新改动列表
--   require("custom.review").stage()        暂存当前文件
--   require("custom.review").reset()        丢弃当前文件改动（带确认）
--
-- 注意：
--   * git status 的 porcelain 输出与当前缓冲区的相对路径都以 cwd 为基准，
--     天然对齐（cwd 需在仓库内，工作流约定从仓库根启动）；
--   * 二进制文件 / 已删除文件 / 目录条目无法打开 diff，会提示跳过；
--   * 面板只在有改动文件时打开；:ReviewStatus 始终可用。
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  panel_width = 50,
  panel_height = 18,
  border = "single",
  position = "right",
  map_keys = false,
  keys = {
    files = "<leader>rv",
    diff = "<leader>rd",
    close = "<leader>rc",
    toggle = "<leader>rt",
    status = "<leader>rs",
  },
}

local cfg = vim.deepcopy(DEFAULTS)
local initialized = false
local commands_created = false
local keymaps_created = false

--- 面板状态
local panel_buf = nil -- 面板缓冲区
local panel_win = nil -- 面板浮动窗口
local entries = {} -- git status 解析结果：[{ xy = string, path = string }]
local sel = 1 -- 面板当前选中项（entries 索引，1-based）
local source_win = nil -- 打开面板前的窗口（关闭面板 / 打开 diff 时回到它）

--- diff 布局状态
local diff_state = nil -- { base_buf, base_win, source_win }

--- 面板高亮的命名空间
local ns = vim.api.nvim_create_namespace("custom_review")

--- 面板缓冲区的 filetype（已加入 winbar / diagnostics 的排除列表）
local PANEL_FT = "review_panel"

-- ============================================================
-- 高亮
-- ============================================================

local HLS = {
  staged = "CustomReviewStaged",
  unstaged = "CustomReviewUnstaged",
  untracked = "CustomReviewUntracked",
}

--- 定义 / 重新应用面板配色（跟随主题的 diff 组；主题切换后由自动命令重调）
local function apply_highlights()
  vim.api.nvim_set_hl(0, HLS.staged, { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, HLS.unstaged, { link = "DiffChange" })
  vim.api.nvim_set_hl(0, HLS.untracked, { link = "Comment" })
end

--- 面板某一行的颜色：按暂存 / 未暂存 / 未跟踪取组名
--- @param xy string git status 的两字节状态码
--- @return string|nil
local function entry_hl(xy)
  local x, y = xy:sub(1, 1), xy:sub(2, 2)
  if x == "?" and y == "?" then
    return HLS.untracked
  end
  if x ~= " " and x ~= "?" then
    return HLS.staged
  end
  if y ~= " " and y ~= "?" then
    return HLS.unstaged
  end
  return nil
end

-- ============================================================
-- git 数据层（全部走 git CLI，不依赖 gitsigns / diffview）
-- ============================================================

--- 执行 git 命令并取 stdout
--- （用 vim.system 而不是 vim.fn.system：Windows 上 vim.fn.system 会把输出里的
---   NUL 字节换成 0x01，而 `git status --porcelain -z` 靠 NUL 分隔路径）
--- @param args string[]
--- @return string|nil 失败（退出码非 0）时返回 nil
local function git_raw(args)
  local res = vim.system(args, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  return res.stdout
end

--- 路径分隔符统一成 "/"（Windows 的 fnamemodify 会返回反斜杠，git 输出恒为 /）
--- @param p string
--- @return string
local function normalize_path(p)
  if vim.fn.has("win32") == 1 then
    return (p:gsub("\\", "/"))
  end
  return p
end

--- 解析 `git status --porcelain=v1 -z` 输出
--- （-z 每条记录是「XY + 空格 + 路径 + NUL」，空格是 XY 与路径之间的分隔，
---   必须一起跳过；路径带空格 / 非 ASCII 也能正确处理；
---   重命名 / 复制是「状态 + 旧路径 + 新路径」三字段，diff 目标用新路径）
--- @param output string
--- @return { xy: string, path: string }[]
local function parse_status(output)
  local result = {}
  local i = 1
  local n = #output
  while i <= n do
    if i + 2 > n then
      break
    end
    local xy = output:sub(i, i + 1)
    i = i + 3 -- 跳过 XY（2 字节）+ 分隔空格
    if i > n then
      break
    end
    local end_pos = output:find("%z", i)
    if not end_pos then
      end_pos = n + 1
    end
    local path = output:sub(i, end_pos - 1)
    i = end_pos + 1
    -- 重命名 / 复制：状态 + 旧路径 + 新路径
    if xy:sub(1, 1) == "R" or xy:sub(1, 1) == "C" then
      local new_end = output:find("%z", i)
      if new_end then
        path = output:sub(i, new_end - 1)
        i = new_end + 1
      end
    end
    if path ~= "" then
      result[#result + 1] = { xy = xy, path = path }
    end
  end
  return result
end

--- 拉取改动文件列表（成功时更新 entries；git 不可用 / 非仓库时返回空表）
--- @return { xy: string, path: string }[]
local function fetch_entries()
  local out = git_raw({ "git", "status", "--porcelain=v1", "-z" })
  if out == nil then
    entries = {}
    return entries
  end
  entries = parse_status(out)
  return entries
end

--- 当前缓冲区的路径（相对 cwd，与 git status 输出对齐；无文件名返回 nil）
--- @return string|nil
local function current_file_path()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if name == "" then
    return nil
  end
  return normalize_path(vim.fn.fnamemodify(name, ":p:."))
end

--- 按路径查条目
--- @param path string
--- @return { xy: string, path: string }|nil
local function find_entry(path)
  for _, e in ipairs(entries) do
    if e.path == path then
      return e
    end
  end
  return nil
end

-- ============================================================
-- 面板
-- ============================================================

--- nvim_open_win 内置边框名（字符串形式）
local BORDER_NAMES = {
  none = true,
  single = true,
  double = true,
  rounded = true,
  solid = true,
  shadow = true,
}

--- 归一化 cfg.border：内置名直接用，false / "" 视为 none，非法值回退 single
--- @return string|table
local function resolve_border()
  local border = cfg.border
  if type(border) == "table" then
    return border
  end
  if border == false or border == nil or border == "" then
    return "none"
  end
  if type(border) == "string" and BORDER_NAMES[border] then
    return border
  end
  return "single"
end

--- 面板理想几何：右侧 / 左侧垂直居中，含边框整体夹回可见区
--- @return table|nil { width, height, row, col, border }
local function panel_geometry()
  local border = resolve_border()
  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return nil
  end
  local adj = border ~= "none" and 1 or 0 -- 边框画在窗口外侧，每边多占 1 格
  local avail_h = math.max(1, ui.height - (vim.o.cmdheight or 0))
  local avail_w = ui.width
  if avail_w < adj * 2 + 1 or avail_h < adj * 2 + 3 then
    return nil
  end
  local width = math.min(cfg.panel_width, avail_w - adj * 2 - 1)
  local height = math.min(math.max(3, #entries + 2), math.max(3, cfg.panel_height), avail_h - adj * 2)
  local row = math.floor((avail_h - height) / 2) - 1
  row = math.max(adj, math.min(row, avail_h - height - adj))
  local col = adj
  if cfg.position ~= "left" then
    col = math.max(adj, avail_w - width - 1)
  end
  return { width = width, height = height, row = row, col = col, border = border }
end

--- 重绘面板：条目列表 + 类型着色 + 尺寸 / 位置 + 光标定位到选中行
local function render_panel()
  local win, buf = panel_win, panel_buf
  -- 拆成两步守卫：lua_ls 无法从「or 链末尾的 nvim_buf_is_valid(buf)」反推 buf 非 nil，
  -- 先单独排除 nil 再校验有效性（否则 buf 传参被判 nil）
  if not win or not buf then
    return
  end
  if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local geo = panel_geometry()
  if not geo then
    return
  end
  local maxw = math.max(4, geo.width - 4) -- 状态列（2 字符 + 空格）之外的路径宽度
  local lines = {}
  for _, e in ipairs(entries) do
    local p = e.path
    if vim.fn.strdisplaywidth(p) > maxw then
      p = vim.fn.strcharpart(p, 0, math.max(1, maxw - 1)) .. "…"
    end
    lines[#lines + 1] = e.xy .. " " .. p
  end
  if #lines == 0 then
    lines = { "  (工作区没有改动)" }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, e in ipairs(entries) do
    local hl = entry_hl(e.xy)
    if hl then
      -- nvim_buf_add_highlight 已废弃，改用 extmark（同一 ns，clear_namespace 一并清理）
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
        end_col = 2,
        hl_group = hl,
      })
    end
  end
  local h = math.max(1, #lines)
  local row = geo.row + math.floor((geo.height - h) / 2)
  vim.api.nvim_win_set_config(win, {
    width = geo.width,
    height = h,
    row = row,
    col = geo.col,
    border = geo.border,
  })
  vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(sel, #lines)), 0 })
end

--- 关闭面板（保留 entries / sel / source_win，重新打开时刷新）
function M.close_panel()
  local win, buf = panel_win, panel_buf
  panel_win, panel_buf = nil, nil
  if win and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_close, win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
  return M
end

-- ============================================================
-- diff 布局（内置 diff 模式，替代 diffview）
-- ============================================================

--- 创建基线 buffer（git show HEAD:path；未跟踪 / 已删除文件用空基线）
--- @param path string
--- @return integer|nil buf, string|nil reason 失败原因（binary）
local function create_base_buffer(path)
  local content = git_raw({ "git", "show", "HEAD:" .. path })
  local base_lines
  if content ~= nil then
    if content:find("\0", 1, true) then
      return nil, "binary"
    end
    base_lines = vim.split(content, "\n", { plain = true })
    if #base_lines > 1 and base_lines[#base_lines] == "" then
      base_lines[#base_lines] = nil
    end
    if #base_lines == 0 then
      base_lines = { "" }
    end
  else
    base_lines = { "" }
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, base_lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  local ft = vim.filetype.match({ filename = path })
  if ft then
    vim.bo[buf].filetype = ft
  end
  vim.api.nvim_buf_set_name(buf, path .. " @HEAD")
  return buf
end

--- 打开指定文件的并排 diff（工作区 vs 基线；已有 diff 布局时先关闭旧的）
--- @param path string
--- @param prefer_win integer|nil 优先使用的窗口（默认 source_win / 当前窗口）
local function open_diff(path, prefer_win)
  if type(path) ~= "string" or path == "" then
    return
  end
  if path:sub(-1) == "/" then
    vim.notify("Review: 目录条目无法打开 diff（" .. path .. "）", vim.log.levels.WARN)
    return
  end
  local e = find_entry(path)
  if e and e.xy:sub(1, 1) == " " and e.xy:sub(2, 2) == "D" then
    vim.notify("Review: 文件已删除，无法打开 diff（" .. path .. "）", vim.log.levels.WARN)
    return
  end
  M.close_diff()
  local win = prefer_win
  if not (win and vim.api.nvim_win_is_valid(win)) then
    win = source_win
  end
  if not (win and vim.api.nvim_win_is_valid(win)) then
    win = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_win(win)
  local ok_edit = pcall(function()
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
  if not ok_edit then
    vim.notify("Review: 无法打开 " .. path, vim.log.levels.WARN)
    return
  end
  local base_buf, reason = create_base_buffer(path)
  if not base_buf then
    if reason == "binary" then
      vim.notify("Review: 二进制文件，跳过 diff（" .. path .. "）", vim.log.levels.WARN)
    end
    return
  end
  vim.cmd("vertical rightbelow split")
  local base_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(base_win, base_buf)
  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(win)
  vim.cmd("diffthis")
  diff_state = { base_buf = base_buf, base_win = base_win, source_win = win }
  vim.notify("Review: " .. path .. "（]c / [c 跳改动）", vim.log.levels.INFO)
end

--- 关闭 diff 布局：关基线窗口、工作区窗口退出 diff 模式、删基线 buffer
function M.close_diff()
  local st = diff_state
  diff_state = nil
  if not st then
    return M
  end
  if vim.api.nvim_win_is_valid(st.base_win) then
    pcall(vim.api.nvim_win_close, st.base_win, true)
  end
  if vim.api.nvim_win_is_valid(st.source_win) then
    pcall(vim.api.nvim_win_call, st.source_win, function()
      vim.cmd("diffoff")
    end)
  end
  if vim.api.nvim_buf_is_valid(st.base_buf) then
    pcall(vim.api.nvim_buf_delete, st.base_buf, { force = true })
  end
  return M
end

--- 面板 <CR>：打开当前选中文件（先关面板，回到来源窗口打开）
local function open_selected()
  local e = entries[sel]
  if not e then
    return
  end
  local win = source_win
  M.close_panel()
  open_diff(e.path, win)
end

--- 面板 q / <Esc>：关闭面板并回到来源窗口
local function panel_quit()
  local win = source_win
  M.close_panel()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
end

--- 面板内键位（进入面板即生效，是面板交互的一部分，不受 map_keys 控制）
--- @param buf integer
local function bind_panel_maps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set(
    "n",
    "<CR>",
    open_selected,
    vim.tbl_extend("force", opts, { desc = "Review: 打开选中文件 diff" })
  )
  vim.keymap.set("n", "q", panel_quit, vim.tbl_extend("force", opts, { desc = "Review: 关闭面板" }))
  vim.keymap.set("n", "<Esc>", panel_quit, vim.tbl_extend("force", opts, { desc = "Review: 关闭面板" }))
end

-- ============================================================
-- 命令对应的动作
-- ============================================================

--- 打开 / 聚焦文件面板（有改动文件才打开；记录来源窗口）
function M.files()
  if panel_win and vim.api.nvim_win_is_valid(panel_win) then
    vim.api.nvim_set_current_win(panel_win)
    return M
  end
  fetch_entries()
  if #entries == 0 then
    M.close_panel()
    vim.notify("Review: 工作区没有改动", vim.log.levels.INFO)
    return M
  end
  source_win = vim.api.nvim_get_current_win()
  local buf = panel_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    panel_buf = buf
  end
  local geo = panel_geometry()
  if not geo then
    return M
  end
  local ok, win = pcall(vim.api.nvim_open_win, buf, true, {
    relative = "editor",
    width = geo.width,
    height = geo.height,
    row = geo.row,
    col = geo.col,
    border = geo.border,
    style = "minimal",
    noautocmd = true,
  })
  if not ok or not vim.api.nvim_win_is_valid(win) then
    return M
  end
  panel_win = win
  vim.bo[buf].filetype = PANEL_FT
  vim.wo[win].winbar = ""
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].wrap = false
  vim.wo[win].list = false
  vim.wo[win].spell = false
  vim.wo[win].cursorline = true -- 当前行即选中项（CursorMoved 同步 sel）
  -- 打开面板时优先定位当前文件
  local cur = current_file_path()
  if cur then
    for i, e in ipairs(entries) do
      if e.path == cur then
        sel = i
        break
      end
    end
  end
  bind_panel_maps(buf)
  render_panel()
  return M
end

--- 刷新改动列表（面板开着时重绘）
function M.refresh()
  fetch_entries()
  render_panel()
  return M
end

--- 打开当前文件（或面板选中项）的 diff
function M.diff()
  if panel_win and vim.api.nvim_win_is_valid(panel_win) then
    open_selected()
    return M
  end
  local path = current_file_path()
  if not path then
    vim.notify("Review: 当前缓冲区没有文件", vim.log.levels.WARN)
    return M
  end
  if not find_entry(path) then
    vim.notify("Review: 当前文件不在改动列表（" .. path .. "）", vim.log.levels.WARN)
    return M
  end
  open_diff(path)
  return M
end

--- 关闭 diff 布局与面板
function M.close()
  M.close_diff()
  M.close_panel()
  return M
end

--- 开关文件面板
function M.toggle()
  if panel_win and vim.api.nvim_win_is_valid(panel_win) then
    M.close_panel()
    return M
  end
  return M.files()
end

--- 审查进度：改动文件数 + 当前文件第几个（一行通知，不弹面板）
function M.status()
  fetch_entries()
  local staged, unstaged, untracked = 0, 0, 0
  for _, e in ipairs(entries) do
    if e.xy == "??" then
      untracked = untracked + 1
    else
      local x, y = e.xy:sub(1, 1), e.xy:sub(2, 2)
      if x ~= " " and x ~= "?" then
        staged = staged + 1
      end
      if y ~= " " and y ~= "?" then
        unstaged = unstaged + 1
      end
    end
  end
  local msg = string.format(
    "Review: 工作区 %d 个改动文件（暂存 %d · 未暂存 %d · 未跟踪 %d）",
    #entries,
    staged,
    unstaged,
    untracked
  )
  local cur = current_file_path()
  local idx = 0
  if cur then
    for i, e in ipairs(entries) do
      if e.path == cur then
        idx = i
        break
      end
    end
  end
  if idx > 0 then
    msg = msg .. string.format("\n当前文件: %d / %d（%s）", idx, #entries, cur)
  end
  vim.notify(msg, vim.log.levels.INFO)
  return M
end

--- 审查目标：面板选中项；面板未开则当前文件（须在改动列表内）
--- @return string|nil path
local function review_target()
  if panel_win and vim.api.nvim_win_is_valid(panel_win) then
    local e = entries[sel]
    if e then
      return e.path
    end
    return nil
  end
  local cur = current_file_path()
  if cur and find_entry(cur) then
    return cur
  end
  return nil
end

--- 暂存当前文件（git add）
function M.stage()
  local path = review_target()
  if not path then
    vim.notify("Review: 没有可暂存的目标文件", vim.log.levels.WARN)
    return M
  end
  if git_raw({ "git", "add", "--", path }) == nil then
    vim.notify("Review: git add 失败（" .. path .. "）", vim.log.levels.ERROR)
    return M
  end
  vim.notify("Review: 已暂存 " .. path, vim.log.levels.INFO)
  M.refresh()
  return M
end

--- 丢弃当前文件的工作区改动（git checkout --，带确认；未跟踪文件不可还原）
function M.reset()
  local path = review_target()
  if not path then
    vim.notify("Review: 没有可还原的目标文件", vim.log.levels.WARN)
    return M
  end
  local e = find_entry(path)
  if e and e.xy == "??" then
    vim.notify("Review: 未跟踪文件无法用 git checkout 还原（" .. path .. "）", vim.log.levels.WARN)
    return M
  end
  local choice = vim.fn.confirm("丢弃 " .. path .. " 的工作区改动？", "&Yes\n&No", 2)
  if choice ~= 1 then
    return M
  end
  if git_raw({ "git", "checkout", "--", path }) == nil then
    vim.notify("Review: git checkout 失败（" .. path .. "）", vim.log.levels.ERROR)
    return M
  end
  vim.notify("Review: 已丢弃 " .. path .. " 的工作区改动", vim.log.levels.INFO)
  M.refresh()
  return M
end

--- 刷新全部缓冲区的磁盘内容（AI 在另一个终端改完写盘后调用）
local function checktime_all()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("checktime")
      end)
    end
  end
end

-- ============================================================
-- 命令与键位
-- ============================================================

local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true

  vim.api.nvim_create_user_command("Review", function()
    checktime_all()
    M.files()
  end, { desc = "Review: 刷新磁盘改动并打开审查文件面板" })

  vim.api.nvim_create_user_command("ReviewFiles", function()
    M.files()
  end, { desc = "Review: 打开 / 聚焦审查文件面板" })

  vim.api.nvim_create_user_command("ReviewDiff", function()
    M.diff()
  end, { desc = "Review: 打开当前文件（或面板选中项）的并排 diff" })

  vim.api.nvim_create_user_command("ReviewClose", function()
    M.close()
  end, { desc = "Review: 关闭 diff 布局与文件面板" })

  vim.api.nvim_create_user_command("ReviewToggle", function()
    M.toggle()
  end, { desc = "Review: 开关文件面板" })

  vim.api.nvim_create_user_command("ReviewStage", function()
    M.stage()
  end, { desc = "Review: 暂存当前文件（git add）" })

  vim.api.nvim_create_user_command("ReviewReset", function()
    M.reset()
  end, { desc = "Review: 丢弃当前文件的工作区改动（带确认）" })

  vim.api.nvim_create_user_command("ReviewStatus", function()
    M.status()
  end, { desc = "Review: 审查进度（一行通知）" })

  vim.api.nvim_create_user_command("ReviewRefresh", function()
    M.refresh()
  end, { desc = "Review: 重新读取 git status 刷新改动列表" })
end

local function ensure_keymaps()
  if keymaps_created or not cfg.map_keys then
    return
  end
  keymaps_created = true

  local keys = cfg.keys or {}
  local function map(lhs, cmd, desc)
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, "<Cmd>" .. cmd .. "<CR>", { silent = true, desc = desc })
    end
  end
  map(keys.files, "ReviewFiles", "Review: 打开 / 聚焦文件面板")
  map(keys.diff, "ReviewDiff", "Review: 打开当前文件 diff")
  map(keys.close, "ReviewClose", "Review: 关闭 diff 与面板")
  map(keys.toggle, "ReviewToggle", "Review: 开关文件面板")
  map(keys.status, "ReviewStatus", "Review: 审查进度")
end

-- ============================================================
-- 入口
-- ============================================================

--- @param opts table|nil
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  apply_highlights()

  if initialized then
    return M
  end
  if vim.fn.executable("git") == 0 then
    vim.notify("custom.review: git 不在 PATH，模块停用", vim.log.levels.WARN)
    return M
  end
  initialized = true

  local augroup = vim.api.nvim_create_augroup("custom_review", { clear = true })

  -- 主题切换后重新应用面板配色
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    desc = "custom.review: 主题切换后重新应用面板配色",
    callback = apply_highlights,
  })

  -- 终端尺寸变化后面板重排
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "custom.review: 终端尺寸变化后面板重排",
    callback = function()
      if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        render_panel()
      end
    end,
  })

  -- 切换缓冲区时刷新改动列表（保持面板最新）
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    desc = "custom.review: 面板打开时刷新改动列表",
    callback = function()
      if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        M.refresh()
      end
    end,
  })

  -- 面板内光标移动 -> 更新选中项
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    desc = "custom.review: 面板内光标移动同步选中项",
    callback = function()
      if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        if vim.api.nvim_get_current_win() == panel_win then
          local cur = vim.api.nvim_win_get_cursor(panel_win)[1]
          sel = math.max(1, math.min(cur, #entries))
        end
      end
    end,
  })

  ensure_commands()
  ensure_keymaps()

  return M
end

return M
