-- TODO: settinngs for yanky.nvim
return {
  "gbprod/yanky.nvim",
  -- enabled = false,
  opts = { ring = {
    history_length = 100,
  },   highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  }, 
},
}
