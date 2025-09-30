-- https://github.com/LuxVim/nvim-luxmotion

return {
  "LuxVim/nvim-luxmotion",
  enabled = false,
  config = function()
    require("luxmotion").setup({
      cursor = {
        duration = 200,
        -- linear, ease-in, ease-out, ease-in-out
        -- easing = "linear",
        easing = "ease-in-out",
        -- easing = "ease-in",
        -- easing = "ease-out",
        enabled = true,
      },
      scroll = {
        duration = 400,
        easing = "ease-in-out",
        enabled = true,
      },
      performance = { enabled = false },
      keymaps = {
        -- cursor = false,
        cursor = true,
        -- scroll = false,
        scroll = true,
      },
    })
  end,
}
