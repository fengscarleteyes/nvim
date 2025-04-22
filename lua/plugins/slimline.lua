-- https://github.com/sschleemilch/slimline.nvim

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.cmd([[Screenkey toggle_statusline_component]])
  end,
})

return {
  "sschleemilch/slimline.nvim",
  dependencies = { "lewis6991/gitsigns.nvim", "echasnovski/mini.icons", "NStefan002/screenkey.nvim" },
  opts = {
    components = {
      center = {
        function()
          return require("screenkey").get_keys()
        end,
      },
    },
  },
}
