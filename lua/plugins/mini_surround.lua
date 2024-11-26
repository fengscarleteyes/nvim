return {
  "echasnovski/mini.surround",
  enabled = false,
  version = false,
  config = function()
    require("mini.surround").setup({
      -- TODO: config keys : add leader keys
      mappings = {
        add = "",
        delete = "",
        find = "",
        find_left = "",
        highlight = "",
        replace = "",
        update_n_lines = "",

        suffix_last = "",
        suffix_next = "",
      },
    })
  end,
}
