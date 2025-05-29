-- https://github.com/nvzone/showkeys

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.cmd([[ShowkeysToggle]])
  end,
})

return {
  "nvzone/showkeys",
  cmd = "ShowkeysToggle",
  enabled = false,
  opts = {
    winopts = {
      focusable = false,
    },
    show_count = true,
    excluded_modes = {}, -- example: {"i"}
  },
}
