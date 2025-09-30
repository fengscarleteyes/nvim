-- https://github.com/nvim-treesitter/nvim-treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  -- enabled = false,
  branch = "main",
  build = ":TSUpdate",
  -- lazy = false,
  config = function()
    require("nvim-treesitter.install").prefer_git = true
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
      "jsonc",
      "markdown",
      "markdown_inline",
      "python",
      "lua",
    }
    local ts = require("nvim-treesitter")
    local is_installed = ts.get_installed()
    local to_install = vim.tbl_filter(function(lang_name)
      for _, value in ipairs(is_installed) do
        if value == lang_name then
          return false
        end
      end
      return true
    end, ensure_installed)
    if #to_install == 0 then
      return
    end
    for _, lang_name in ipairs(to_install) do
      ts.install(lang_name) -- :wait(300000)
    end
  end,
}
