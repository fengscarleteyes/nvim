-- https://github.com/hrsh7th/nvim-insx

-- TODO: custom pair

return {
  "hrsh7th/nvim-insx",
  enabled = false,
  config = function()
    -- require("insx.preset.standard").setup()
    local insx = require("insx")
    insx.add(
      "'",
      insx.with(
        require("insx.recipe.auto_pair")({
          open = "'",
          close = "'",
        }),
        {
          insx.with.in_string(false),
          insx.with.in_comment(false),
          insx.with.nomatch([[\\\%#]]),
          insx.with.nomatch([[\a\%#]]),
        }
      )
    )
  end,
}
