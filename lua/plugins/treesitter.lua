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
        enable = false,
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
        enable = false,
        swap_next = {
          ["<leader>tn"] = { query = "@parameter.inner", desc = "Swap parameter inner next" },
        },
        swap_previous = {
          ["<leader>tp"] = { query = "@parameter.inner", desc = "Swap parameter inner previous" },
        },
      },
      move = {
        enable = false,
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

--TODO: move to keymap config
-- 1. **@assignment.inner / @assignment.outer**: 选择赋值语句的内部或外部部分。例如，`a = b + c` 中，`inner` 可能选择 `b + c`，而 `outer` 选择整个赋值语句。
-- 2. **@assignment.lhs / @assignment.rhs**: 分别选择赋值语句的左侧（left-hand side）和右侧（right-hand side）。例如，`a = b + c` 中，`lhs` 选择 `a`，`rhs` 选择 `b + c`。
-- 3. **@attribute.inner / @attribute.outer**: 选择属性（如 Python 中的 `obj.attr`）的内部或外部部分。
-- 4. **@block.inner / @block.outer**: 选择代码块（如 `{}` 包围的部分）的内部或外部部分。
-- 5. **@call.inner / @call.outer**: 选择函数调用的内部或外部部分。例如，`foo(bar)` 中，`inner` 可能选择 `bar`，而 `outer` 选择整个 `foo(bar)`。
-- 6. **@class.inner / @class.outer**: 选择类定义的内部或外部部分。
-- 7. **@comment.inner / @comment.outer**: 选择注释的内部或外部部分。
-- 8. **@conditional.inner / @conditional.outer**: 选择条件语句（如 `if` 语句）的内部或外部部分。
-- 9. **@frame.inner / @frame.outer**: 选择代码框架（如函数或类的上下文）的内部或外部部分。
-- 10. **@function.inner / @function.outer**: 选择函数定义的内部或外部部分。
-- 11. **@loop.inner / @loop.outer**: 选择循环语句（如 `for` 或 `while` 循环）的内部或外部部分。
-- 12. **@number.inner**: 选择数字的内部部分。
-- 13. **@parameter.inner / @parameter.outer**: 选择函数参数的内部或外部部分。
-- 14. **@regex.inner / @regex.outer**: 选择正则表达式的内部或外部部分。
-- 15. **@return.inner / @return.outer**: 选择 `return` 语句的内部或外部部分。
-- 16. **@scopename.inner**: 选择作用域名称的内部部分。
-- 17. **@statement.outer**: 选择整个语句的外部部分。
-- 这些文本对象可以帮助你在代码编辑器中更精确地选择和操作代码的不同部分，从而提高编辑效率。
