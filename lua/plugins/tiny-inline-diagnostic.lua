-- https://github.com/rachartier/tiny-inline-diagnostic.nvim

return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  priority = 1000,
  opts = {
    -- "modern", "classic", "minimal", "powerline",
    -- "ghost", "simple", "nonerdfont", "amongus"
    preset = "classic",
    options = {
      show_source = {
        enabled = true,
        if_many = true,
      },
      use_icons_from_diagnostic = false,
      multilines = {
        enabled = true,
        always_show = true,
      },
      show_all_diags_on_cursorline = true,
    },
    disabled_ft = {},
  },
  config = function(_, opts)
    require("tiny-inline-diagnostic").setup(opts)
    vim.diagnostic.config({ virtual_text = false })
  end,
}
