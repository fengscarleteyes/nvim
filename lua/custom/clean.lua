-- ============================================================
-- 维护类命令
-- ------------------------------------------------------------
--   :RemoveStateDir   删除 Neovim 的 state 目录（vim.fn.stdpath("state")）
--   :RemoveShadaDir   删除 state 目录下的 shada 目录（state/shada）
--
-- 两个命令都会在清理后立即 :qall! 强制退出：
-- 目录已被清空，若继续运行，Neovim 会在退出时把它们重新写回去。
--
-- 删除不可恢复，执行前会要求输入 Y/y 确认，其它输入（含 Esc 取消）视为放弃。
-- ============================================================

--- 目录存在则递归删除
--- @param path string 目录路径
local function remove_dir(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.fn.delete(path, "rf")
  end
end

--- 请求确认后执行清理，并强制退出
--- @param name string 命令名（用于提示文案）
--- @param cleaner fun() 实际清理动作
local function confirm_and_clean(name, cleaner)
  vim.ui.input({ prompt = name .. ' Enter "Y/y" or "N/n": ' }, function(input)
    -- Esc 取消时 input 为 nil，统一按“取消”处理
    if string.lower(input or "") ~= "y" then
      return
    end
    cleaner()
    vim.cmd("qall!") -- 强制退出（不保存），避免退出时又被写回
  end)
end

vim.api.nvim_create_user_command("RemoveStateDir", function()
  confirm_and_clean("RemoveStateDir", function()
    remove_dir(vim.fn.stdpath("state"))
  end)
end, { desc = "clean nvim state directory" })

vim.api.nvim_create_user_command("RemoveShadaDir", function()
  confirm_and_clean("RemoveShadaDir", function()
    -- shada 位于 state 目录下（Windows / *nix 路径分隔符均可）
    remove_dir(vim.fn.stdpath("state") .. "/shada")
  end)
end, { desc = "clean nvim shada directory" })
