return {
  "CRAG666/code_runner.nvim",
  -- opts = {
  --   filetype_path = function()
  --     if vim.fn.has("win32") == 1 then
  --       return vim.fn.expand("~/AppData/Local/nvim/code_runner.json")
  --     elseif vim.fn.has("unix") == 1 then
  --       return vim.fn.expand("~/.config/nvim/code_runner.json")
  --     end
  --   end,
  --   project_path = function()
  --     if vim.fn.has("win32") == 1 then
  --       return vim.fn.expand("~/AppData/Local/nvim/project_manager.json")
  --     elseif vim.fn.has("unix") == 1 then
  --       return vim.fn.expand("~/.config/nvim/project_manager.json")
  --     end
  --   end,
  -- },
  opts = function()
    if vim.fn.has("win32") == 1 then
      return {
        filetype_path = vim.fn.expand("~/AppData/Local/nvim/code_runner.json"),
        project_path = vim.fn.expand("~/AppData/Local/nvim/project_manager.json"),
      }
    elseif vim.fn.has("unix") == 1 then
      return {
        filetype_path = vim.fn.expand("~/.config/nvim/code_runner.json"),
        project_path = vim.fn.expand("~/.config/nvim/project_manager.json"),
      }
    end
  end,
}
