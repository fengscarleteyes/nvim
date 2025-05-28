local function clean_nvim_state_dir()
  local state_dir = vim.fn.stdpath("state")
  if vim.fn.isdirectory(state_dir) == 1 then
    vim.fn.delete(state_dir, "rf")
  end
end

vim.api.nvim_create_user_command("CleanNvimStateDir", clean_nvim_state_dir, { desc = "clean nvim state directory" })
