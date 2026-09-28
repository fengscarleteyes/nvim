-- lua/custom/lsp.lua
-- LSP 实用功能集
-- ------------------------------------------------------------
-- 提供以下功能：
--   * 悬停信息（hover）
--   * 跳转到定义（goto definition）
--   * 代码操作（code action）
--   * 预览定义（peek definition）
--   * LSP 查找器（查找定义/引用/实现等）
--   * 重命名（rename）
--
-- 功能预绑定快捷键，但默认不启用，需通过配置激活。
-- 配色跟随主题：LspReferenceText / LspReferenceRead / LspReferenceWrite。
--
-- API：
--   require("custom.lsp").setup([opts])   初始化（幂等）
--   require("custom.lsp").hover()         显示悬停信息
--   require("custom.lsp").goto()         跳转到定义
--   require("custom.lsp").code_action()   显示代码操作
--   require("custom.lsp").peek()          预览定义
--   require("custom.lsp").finder()        打开 LSP 查找器
--   require("custom.lsp").rename()        重命名
--
-- 用户命令：
--   :LspHover         显示悬停信息
--   :LspGoto          跳转到定义
--   :LspCodeAction    显示代码操作
--   :LspPeek          预览定义
--   :LspFinder        打开 LSP 查找器
--   :LspRename        重命名
--
-- 配置（M.setup(opts)，括号内为默认值）：
--   map_keys          boolean        false    是否绑定默认快捷键
--   hover_keys        string         "K"     悬停触发键
--   goto_keys         string         "gd"    跳转定义触发键
--   action_keys       string         "ga"    代码操作触发键
--   peek_keys         string         "gP"    预览定义触发键
--   finder_keys       string         "gr"    LSP 查找器触发键
--   rename_keys       string         "gn"    重命名触发键
--   disable_filetypes table          {}      不启用插件的 filetype
--
-- 使用示例：
--   -- 基础用法（不绑定快捷键，通过命令使用）
--   require("custom.lsp").setup()
--
--   -- 启用快捷键
--   require("custom.lsp").setup({
--     map_keys = true,
--   })
--
--   -- 自定义快捷键
--   require("custom.lsp").setup({
--     map_keys = true,
--     hover_keys = "gh",
--     goto_keys = "gd",
--     action_keys = "ga",
--     peek_keys = "gP",
--     finder_keys = "gr",
--     rename_keys = "grn",
--   })
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  map_keys = false,
  hover_keys = "K",
  goto_keys = "gd",
  action_keys = "ga",
  peek_keys = "gP",
  finder_keys = "gr",
  rename_keys = "gn",
  disable_filetypes = {},
}

local cfg = vim.deepcopy(DEFAULTS)
local initialized = false
local commands_created = false
local keymaps_created = false

--- 判断当前缓冲区是否可以使用 LSP 功能
--- @return boolean
local function can_use_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if vim.tbl_contains(cfg.disable_filetypes or {}, ft) then
    return false
  end

  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  return #clients > 0
end

--- 获取当前缓冲区可用的 LSP 客户端
--- @return lsp.Client[] clients
local function get_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.lsp.get_active_clients({ bufnr = bufnr })
end

--- 显示悬停信息
function M.hover()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf.hover(params)
end

--- 跳转到定义
function M.goto()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.definition()
end

--- 代码操作
function M.code_action()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.code_action()
end

--- 预览定义（浮动窗口）
function M.peek()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf.definition(params)
end

--- LSP 查找器（查找定义、引用、实现等）
function M.finder()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.references()
end

--- 重命名
function M.rename()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.rename()
end

--- 声明（declaration）
function M.declaration()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.declaration()
end

--- 实现（implementation）
function M.implementation()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.implementation()
end

--- 类型定义（type definition）
function M.type_definition()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.type_definition()
end

--- 格式化
function M.format()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.format({ async = true })
end

--- 文档符号
function M.document_symbol()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.document_symbol()
end

--- 工作区符号
function M.workspace_symbol()
  if not can_use_lsp() then
    vim.notify("当前缓冲区没有活动的 LSP 客户端", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.workspace_symbol()
end

-- ============================================================
-- 命令与键位
-- ============================================================

local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true

  vim.api.nvim_create_user_command("LspHover", function()
    M.hover()
  end, { desc = "LSP: 显示悬停信息" })

  vim.api.nvim_create_user_command("LspGoto", function()
    M.goto()
  end, { desc = "LSP: 跳转到定义" })

  vim.api.nvim_create_user_command("LspCodeAction", function()
    M.code_action()
  end, { desc = "LSP: 显示代码操作" })

  vim.api.nvim_create_user_command("LspPeek", function()
    M.peek()
  end, { desc = "LSP: 预览定义" })

  vim.api.nvim_create_user_command("LspFinder", function()
    M.finder()
  end, { desc = "LSP: 查找引用/定义" })

  vim.api.nvim_create_user_command("LspRename", function()
    M.rename()
  end, { desc = "LSP: 重命名" })

  vim.api.nvim_create_user_command("LspDeclaration", function()
    M.declaration()
  end, { desc = "LSP: 跳转到声明" })

  vim.api.nvim_create_user_command("LspImplementation", function()
    M.implementation()
  end, { desc = "LSP: 跳转到实现" })

  vim.api.nvim_create_user_command("LspTypeDefinition", function()
    M.type_definition()
  end, { desc = "LSP: 跳转到类型定义" })

  vim.api.nvim_create_user_command("LspFormat", function()
    M.format()
  end, { desc = "LSP: 格式化" })

  vim.api.nvim_create_user_command("LspDocumentSymbol", function()
    M.document_symbol()
  end, { desc = "LSP: 文档符号" })

  vim.api.nvim_create_user_command("LspWorkspaceSymbol", function()
    M.workspace_symbol()
  end, { desc = "LSP: 工作区符号" })
end

local function ensure_keymaps()
  if keymaps_created or not cfg.map_keys then
    return
  end
  keymaps_created = true

  local function map(lhs, fn, desc)
    if type(lhs) == "string" and lhs ~= "" then
      vim.keymap.set("n", lhs, fn, { silent = true, desc = desc })
    end
  end

  map(cfg.hover_keys, M.hover, "LSP: 悬停信息")
  map(cfg.goto_keys, M.goto, "LSP: 跳转到定义")
  map(cfg.action_keys, M.code_action, "LSP: 代码操作")
  map(cfg.peek_keys, M.peek, "LSP: 预览定义")
  map(cfg.finder_keys, M.finder, "LSP: 查找引用")
  map(cfg.rename_keys, M.rename, "LSP: 重命名")
end

-- ============================================================
-- 入口
-- ============================================================

--- @param opts table|nil
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})

  if opts and opts.disable_filetypes ~= nil then
    cfg.disable_filetypes = opts.disable_filetypes
  end

  if initialized then
    ensure_keymaps()
    return M
  end
  initialized = true

  ensure_commands()
  ensure_keymaps()

  return M
end

return M
