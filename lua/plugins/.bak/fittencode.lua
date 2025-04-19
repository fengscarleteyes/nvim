return {
  "luozhiya/fittencode.nvim",
  enabled = false,
  opts = {
    actions = {},
    use_default_keymaps = false,
    inline_completion = { enable = true },
    source_completion = { enable = false },
    completion_mode = "inline",
    log = {
      level = vim.log.levels.WARN,
      max_size = 10,
    },
  },
  config = function(_, opts)
    require("fittencode").setup(opts)
  end,
}
