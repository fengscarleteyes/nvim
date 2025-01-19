-- https://github.com/ibhagwan/fzf-lua
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context",
    "MeanderingProgrammer/render-markdown.nvim",
    "mfussenegger/nvim-dap",
  },
  -- opts = { "telescope" },
  config = function()
    local actions = require("fzf-lua").actions
    require("fzf-lua").setup({
      winopts = {
        -- fullscreen = true,
        treesitter = {
          enabled = true,
        },
      },
      fzf_opts = {
        -- ["--no-multi"] = "",
        ["--layout"] = "reverse",
        ["--marker"] = "+",
        ["--highlight-line"] = true,
        ["--ansi"] = true,
        ["--info"] = "inline-right",
      },
      actions = {
        files = {
          ["enter"] = actions.file_edit_or_qf,
          -- ["enter"] = actions.file_switch_or_edit,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["alt-q"] = actions.file_sel_to_qf,
          ["alt-Q"] = actions.file_sel_to_ll,
        },
      },
    })
  end,
}
