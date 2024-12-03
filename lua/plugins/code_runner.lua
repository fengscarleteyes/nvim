return {
  "CRAG666/code_runner.nvim",
  opts = {
    filetype_path = vim.fs.joinpath(vim.fn.stdpath("config"), "code_runner.json"),
    project_path = vim.fs.joinpath(vim.fn.stdpath("config"), "project_manager.json"),
  },
}
