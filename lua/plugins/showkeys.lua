-- https://github.com/nvzone/showkeys

return {
  "nvzone/showkeys",
  -- cmd = "ShowkeysToggle",
  opts = {
    winopts = {
      focusable = false,
    },
    show_count = true,
    excluded_modes = {}, -- example: {"i"}
  },
  config = function(_, opts)
    require("showkeys").setup(opts)
    vim.cmd([[ShowkeysToggle]])
  end,
}
