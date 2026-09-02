vim.pack.add({
  "https://github.com/sschleemilch/slimline.nvim",
  "https://github.com/NStefan002/screenkey.nvim",
})

require("slimline").setup({
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
})
