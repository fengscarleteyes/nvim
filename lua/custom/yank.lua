-- ============================================================
-- 复制（yank）后短暂高亮被复制的内容（标准插件写法：返回 M）
-- ------------------------------------------------------------
-- 高亮组默认用 IncSearch（跟随配色方案），时长默认 2000ms。
--
-- 配置（M.setup(opts)）：
--   higroup  string  "IncSearch"  高亮组名（跟随配色方案）
--   timeout  number  2000         高亮时长（毫秒）
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  higroup = "IncSearch",
  timeout = 2000,
}

local initialized = false -- setup() 是否已完成注册

--- 启用复制高亮（幂等：重复调用只注册一次）
--- @param opts table|nil 可选 { higroup = string, timeout = number }
--- @return table M
function M.setup(opts)
  local cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  if initialized then
    return M
  end
  initialized = true

  -- clear = true：重复 setup 不会累积重复的自动命令
  local augroup = vim.api.nvim_create_augroup("custom_yank_highlight", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "custom: highlight yanked text",
    callback = function()
      vim.highlight.on_yank({ higroup = cfg.higroup, timeout = cfg.timeout })
    end,
  })

  return M
end

return M
