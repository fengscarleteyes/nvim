return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        insert = "",
        insert_line = "",
        normal = "",
        normal_cur = "",
        normal_line = "",
        normal_cur_line = "",
        visual = "",
        visual_line = "",
        delete = "d",
        change = "",
        change_line = "",
    },
    })
  end,
}
