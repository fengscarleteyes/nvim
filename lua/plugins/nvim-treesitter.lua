-- https://github.com/nvim-treesitter/nvim-treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
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
      "jsonc",
      "markdown",
      "markdown_inline",
      "python",
      "lua",
    }
    ts.install(ensure_installed) -- :wait(300000)
  end,
}
-- require'nvim-treesitter'.install { 'rust', 'javascript', 'zig' }
-- require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000) -- wait max. 5 minutes
