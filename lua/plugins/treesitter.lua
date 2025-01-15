return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "VeryLazy",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "bash",
      "lua",
      "python",
      "vim",
      "vimdoc",
      "regex",
      "json",
      "jsonc",
      "yaml",
      "toml",
      "html",
      "javascript",
      "typescript",
      "markdown",
      "markdown_inline",
    },
    sync_install = true,
    auto_install = true,
    -- ignore_install = { "c" },
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
    -- TODO: set keymapping
    textobjects = {
      select = { enable = false },
      swap = { enable = false },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = { query = "@class.outer", desc = "Next class start" },
          -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
          ["]o"] = "@loop.*",
          -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
          -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
          -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
          ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
        -- Below will go to either the start or the end, whichever is closer.
        -- Use if you want more granular movements
        -- Make it even more gradual by adding multiple queries and regex.
        goto_next = {
          ["]d"] = "@conditional.outer",
        },
        goto_previous = {
          ["[d"] = "@conditional.outer",
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
