return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "VeryLazy",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "bash",
      "nu",
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
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["<leader>tfo"] = { query = "@function.outer", desc = "Select function outer" },
          ["<leader>tfi"] = { query = "@function.inner", desc = "Select function inner" },
          ["<leader>tco"] = { query = "@class.outer", desc = "Select class outer" },
          ["<leader>tci"] = { query = "@class.inner", desc = "Select class inner" },
          ["<leader>tls"] = { query = "@local.scope", desc = "Select language scope" },
        }, -- in "v" mode
        include_surrounding_whitespace = false,
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>tn"] = { query = "@parameter.inner", desc = "Swap parameter inner next" },
        },
        swap_previous = {
          ["<leader>tp"] = { query = "@parameter.inner", desc = "Swap parameter inner previous" },
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["<leader>t]f"] = { query = "@function.outer", desc = "Next function start" },
          ["<leader>t]c"] = { query = "@class.outer", desc = "Next class start" },
          ["<leader>t]o"] = { query = { "@loop.inner", "@loop.outer" }, desc = "Next loop start" },
          ["<leader>t]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          ["<leader>t]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        goto_next_end = {
          ["<leader>t]F"] = { query = "@function.outer", desc = "Next function end" },
          ["<leader>t]C"] = { query = "@class.outer", desc = "Next class end" },
        },
        goto_previous_start = {
          ["<leader>t[f"] = { query = "@function.outer", desc = "Previous function start" },
          ["<leader>t[c"] = { query = "@class.outer", desc = "Previous class start" },
        },
        goto_previous_end = {
          ["<leader>t[F"] = { query = "@function.outer", desc = "Previous function end" },
          ["<leader>t[C"] = { query = "@class.outer", desc = "Previous class end" },
        },
        goto_next = {
          ["<leader>t]d"] = { query = "@conditional.outer", desc = "Next conditional start" },
        },
        goto_previous = {
          ["<leader>t[d"] = { query = "@conditional.outer", desc = "Previous conditional start" },
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}

-- @assignment.inner
-- @assignment.lhs
-- @assignment.outer
-- @assignment.rhs
-- @attribute.inner
-- @attribute.outer
-- @block.inner
-- @block.outer
-- @call.inner
-- @call.outer
-- @class.inner
-- @class.outer
-- @comment.inner
-- @comment.outer
-- @conditional.inner
-- @conditional.outer
-- @frame.inner
-- @frame.outer
-- @function.inner
-- @function.outer
-- @loop.inner
-- @loop.outer
-- @number.inner
-- @parameter.inner
-- @parameter.outer
-- @regex.inner
-- @regex.outer
-- @return.inner
-- @return.outer
-- @scopename.inner
-- @statement.outer
