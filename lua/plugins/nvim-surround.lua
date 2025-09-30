-- https://github.com/kylechui/nvim-surround

-- TODO: keymaps

return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        insert = false,
        insert_line = false,
        normal = false,
        normal_cur = "<leader>ss",
        normal_line = false,
        normal_cur_line = "<leader>sS",
        visual = "<leader>sv",
        visual_line = "<leader>sV",
        delete = "<leader>sd",
        change = "<leader>sc",
        change_line = "<leader>sC",
      },
    })
  end,
}
