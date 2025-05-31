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

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client:supports_method('textDocument/completion') then
--       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd({'InsertCharPre', 'TextChangedI'}, {
--   callback = function()
--     -- 避免重复触发和干扰
--     if vim.fn.pumvisible() == 1 
--        or vim.fn.state('m') == 'm' 
--        or vim.v.char == '' then
--       return
--     end
    
--     -- 获取当前上下文
--     local line = vim.api.nvim_get_current_line()
--     local col = vim.api.nvim_win_get_cursor(0)[2]
    
--     -- 至少输入1个字符后才触发
--     if col > 0 then
--       -- 延迟触发以避免干扰正常输入
--       vim.defer_fn(function()
--         if vim.fn.pumvisible() == 0 then
--           vim.api.nvim_feedkeys(
--             vim.keycode('<C-x><C-n>'), 'n', false
--           )
--         end
--       end, 10)  -- 10ms延迟
--     end
--   end
-- })