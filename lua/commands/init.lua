local function clean_nvim_state_dir()
  local state_dir = vim.fn.stdpath("state")
  if vim.fn.isdirectory(state_dir) == 1 then
    vim.fn.delete(state_dir, "rf")
  end
end

vim.api.nvim_create_user_command(
  "CleanNvimStateDir", -- command name
  clean_nvim_state_dir,
  { desc = "clean nvim state directory" }
)

-- 默认打开为新的tab
-- vim.api.nvim_create_autocmd("BufAdd", {
--   callback = function()
--       -- 检查是否已经有至少一个标签页
--       if vim.fn.tabpagenr("$") == 1 and vim.fn.winnr("$") == 1 then
--           -- 第一个文件已经在初始标签页中打开，不需要做任何操作
--           return
--       end
--       -- 在新标签页中打开
--       vim.cmd("tabedit " .. vim.fn.expand("<afile>"))
--       -- 关闭原来的缓冲区
--       vim.cmd("bdelete #")
--   end
-- })