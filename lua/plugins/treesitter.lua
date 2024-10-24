return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  opts = {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "regex",
      "json",
      "jsonc",
      "xml",
      "yaml",
      "toml",
      "html",
      "javascript",
      "markdown",
      "markdown_inline",
      "python",
      "toml",
      "typescript",
    },
    sync_install = true,
    auto_install = true,
    ignore_install = { "c" },
    autopairs = { enable = true },
    indent = { enable = true },
    highlight = {
      enable = true,
      -- disable = function(lang, buf)
      --   local max_filesize = 100 * 1024 -- 100 KB
      --   local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      --   if ok and stats and stats.size > max_filesize then
      --     return true
      --   end
      -- end,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>", -- 扩展选择 V光标选择部分
        node_incremental = "<CR>", -- 扩展选择 块部分
        node_decremental = "<BS>", -- 缩小选择 块部分
        scope_incremental = "<TAB>", -- 全选 V光标空白部分后 全选
      },
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
