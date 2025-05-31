-- https://github.com/sschleemilch/slimline.nvim

return {
  "sschleemilch/slimline.nvim",
  dependencies = { "lewis6991/gitsigns.nvim", "echasnovski/mini.icons", "NStefan002/screenkey.nvim" },
  event = "VimEnter",
  opts = {
    components = {
      center = {
        function()
          return require("screenkey").get_keys()
        end,
      },
    },
  },
  config = function(_,opts)
    require("slimline").setup(opts)
    vim.cmd([[Screenkey toggle_statusline_component]])
  end
}


