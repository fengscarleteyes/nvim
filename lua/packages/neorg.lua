-- https://github.com/nvim-neorg/neorg/wiki/Setup-Guide
local function get_sep()
  local sep = ""
  if vim.uv.os_uname().sysname == "Windows_NT" then
    sep = "\\"
  else
    sep = "/"
  end
  return sep
end

return {
  "nvim-neorg/neorg",
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  -- config = true,
  opts = {
    load = {
      ["core.defaults"] = {},
      ["core.concealer"] = {},
      ["core.dirman"] = {
        config = {
          workspaces = {
            notes = vim.fn.stdpath("config") .. get_sep() .. "notes",
          },
        },
      },
      ["core.keybinds"] = {
        config = {
          default_keybinds = false,
        },
      },
    },
  },
}
