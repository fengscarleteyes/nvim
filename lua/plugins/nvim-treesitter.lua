-- https://github.com/nvim-treesitter/nvim-treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local function is_installed(check_name, check_table)
      for _, value in ipairs(check_table) do
        if value == check_name then
          return true
        end
      end
      return false
    end
    require("nvim-treesitter.install").prefer_git = true
    local ts = require("nvim-treesitter")
    local ensure_installed = {
      "vim",
      "vimdoc",
      "html",
      "css",
      "javascript",
      "typescript",
      "regex",
      "yaml",
      "toml",
      "json",
      "markdown",
      "markdown_inline",
      "python",
      "lua",
    }
    for _, lang_name in ipairs(ensure_installed) do
      local installed = ts.get_installed()
      if not is_installed(lang_name, installed) then
        ts.install(lang_name) -- :wait(300000)
      end
    end
  end,
}
-- require'nvim-treesitter'.install { 'rust', 'javascript', 'zig' }
-- require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000) -- wait max. 5 minutes
