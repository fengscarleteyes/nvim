-- https://github.com/ibhagwan/fzf-lua
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context",
    "MeanderingProgrammer/render-markdown.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    local actions = require("fzf-lua").actions
    require("fzf-lua").setup({
      winopts = {
        -- fullscreen = true,
        treesitter = {
          enabled = true,
        },
      },
      actions = {
        files = {
          -- ["enter"] = actions.file_edit_or_qf,
          ["enter"] = actions.file_switch_or_edit,
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
