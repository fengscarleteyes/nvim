-- https://github.com/kylechui/nvim-surround

-- TODO: keymaps
-- <Plug>(nvim-surround-insert)
-- <Plug>(nvim-surround-insert-line)
-- <Plug>(nvim-surround-normal)
-- <Plug>(nvim-surround-normal-cur)
-- <Plug>(nvim-surround-normal-line)
-- <Plug>(nvim-surround-normal-cur-line)
-- <Plug>(nvim-surround-visual)
-- <Plug>(nvim-surround-visual-line)
-- <Plug>(nvim-surround-delete)
-- <Plug>(nvim-surround-change)
-- <Plug>(nvim-surround-change-line)

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
