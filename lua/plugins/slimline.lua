-- https://github.com/sschleemilch/slimline.nvim

return {
  "sschleemilch/slimline.nvim",
  enabled = false,
  dependencies = "NStefan002/screenkey.nvim",
  event = "VimEnter",
  opts = {
    bold = false,
    style = "bg",
    -- style = "fg",
    components = {
      center = {
        -- "  ",
        function()
          return " 󱩼 " .. require("screenkey").get_keys()
        end,
      },
    },
    -- Spacing configuration
    spaces = {
      components = " ", -- string between components
      left = "", -- string at the start of the line
      right = "", -- string at the end of the line
    },
    -- Seperator configuartion
    sep = {
      hide = {
        first = true, -- hides the first separator of the line
        last = true, -- hides the last separator of the line
      },
      left = "", -- left separator of components
      right = "", -- right separator of components
    },
  },
  config = function(_, opts)
    require("slimline").setup(opts)
    vim.cmd([[Screenkey toggle_statusline_component]])
  end,
}
