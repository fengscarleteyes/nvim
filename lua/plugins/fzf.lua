-- https://github.com/ibhagwan/fzf-lua
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context",
    "MeanderingProgrammer/render-markdown.nvim",
    "mfussenegger/nvim-dap",
  },
  opts = { "telescope" },
  config = function()
    -- local actions = require("fzf-lua").actions
    require("fzf-lua").setup({
      winopts = {
        fullscreen = true,
        treesitter = {
          enabled = true,
        },
      },
      fzf_opts = {
        ["--no-multi"] = true,
        ["--layout"] = "reverse",
        ["--marker"] = "+",
        ["--highlight-line"] = true,
        ["--ansi"] = true,
        ["--info"] = "inline-right",
      },
      actions = {
        files = { true },
      },
      defaults = {
        file_icons = true,
        -- copen = "topleft copen",
        hidden = true,
      },
      -- grep = {
      --   hidden = true,
      -- },
    })
  end,
}
