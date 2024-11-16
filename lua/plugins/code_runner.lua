return {
  "CRAG666/code_runner.nvim",
  opts = function()
    if vim.fn.has("win32") == 1 then
      filetype_path = vim.fn.expand("~/AppData/Local/nvim/code_runner.json")
      project_path = vim.fn.expand("~/AppData/Local/nvim/project_manager.json")
    elseif vim.fn.has("unix") == 1 then
      filetype_path = vim.fn.expand("~/.config/nvim/code_runner.json")
      project_path = vim.fn.expand("~/.config/nvim/project_manager.json")
    end
    return {
      filetype_path,
      project_path,
    }
  end,
}
