-- https://github.com/hrsh7th/nvim-insx

-- TODO: custom pair

return {
  "hrsh7th/nvim-insx",
  -- enabled = false,
  config = function()
    require("insx.preset.standard").setup()
  end,
}
