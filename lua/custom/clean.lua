-- ============================================================
-- 维护类命令（标准插件写法：返回 M，由 M.setup() 生效）
-- ------------------------------------------------------------
--   :RemoveStateDir   删除 Neovim 的 state 目录（vim.fn.stdpath("state")）
--   :RemoveShadaDir   删除 state 目录下的 shada 目录（state/shada）
--
-- 两个命令默认都会在清理后立即 :qall! 强制退出：
-- 目录已被清空，若继续运行，Neovim 会在退出时把它们重新写回去。
--
-- 删除不可恢复，执行前会要求输入 Y/y 确认，其它输入（含 Esc 取消）视为放弃。
--
-- 配置（M.setup(opts)）：
--   quit_after_clean  boolean  true  清理后是否立即强制退出
--
-- API：
--   clean.remove_state_dir()  清理 state 目录（等价于 :RemoveStateDir）
--   clean.remove_shada_dir()  清理 shada 目录（等价于 :RemoveShadaDir）
-- ============================================================
local M = {}

--- 默认配置
local DEFAULTS = {
  quit_after_clean = true,
}

local cfg = vim.deepcopy(DEFAULTS)
local initialized = false -- setup() 是否已完成注册

--- 目录存在则递归删除
--- @param path string 目录路径
local function remove_dir(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.fn.delete(path, "rf")
  end
end

--- 请求确认后执行清理，并按配置决定是否强制退出
--- @param name string 命令名（用于提示文案）
--- @param cleaner fun() 实际清理动作
local function confirm_and_clean(name, cleaner)
  vim.ui.input({ prompt = name .. ' Enter "Y/y" or "N/n": ' }, function(input)
    -- Esc 取消时 input 为 nil，统一按“取消”处理
    if string.lower(input or "") ~= "y" then
      return
    end
    cleaner()
    if cfg.quit_after_clean then
      vim.cmd("qall!") -- 强制退出（不保存），避免退出时又被写回
    end
  end)
end

--- 清理 Neovim 的 state 目录
function M.remove_state_dir()
  confirm_and_clean("RemoveStateDir", function()
    remove_dir(vim.fn.stdpath("state"))
  end)
end

--- 清理 state 目录下的 shada 目录
function M.remove_shada_dir()
  confirm_and_clean("RemoveShadaDir", function()
    -- shada 位于 state 目录下（Windows / *nix 路径分隔符均可）
    remove_dir(vim.fn.stdpath("state") .. "/shada")
  end)
end

--- 注册用户命令（幂等：重复调用只注册一次）
--- @param opts table|nil 可选 { quit_after_clean = boolean }
--- @return table M
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  if initialized then
    return M
  end
  initialized = true

  vim.api.nvim_create_user_command("RemoveStateDir", M.remove_state_dir, {
    desc = "clean nvim state directory",
  })
  vim.api.nvim_create_user_command("RemoveShadaDir", M.remove_shada_dir, {
    desc = "clean nvim shada directory",
  })

  return M
end

return M
