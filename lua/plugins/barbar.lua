return {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    animation = true,
    auto_hide = false,
    tabpages = true,
    clickable = true,
    icons = {
      -- 
      separator = { left = "", right = "" },
      modified = { button = " " },
      pinned = { button = "", filename = true },
      -- preset = "default", -- 'default', 'powerline', or 'slanted'
      -- preset = "slanted", -- 'default', 'powerline', or 'slanted'
      preset = "powerline", -- 'default', 'powerline', or 'slanted'
      buffer_index = true,
      -- buffer_number = true,
      button = false,
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = { enabled = true },
        [vim.diagnostic.severity.WARN] = { enabled = true },
        [vim.diagnostic.severity.INFO] = { enabled = true },
        [vim.diagnostic.severity.HINT] = { enabled = true },
      },
      gitsigns = {
        added = { enabled = true, icon = "+" },
        changed = { enabled = true, icon = "~" },
        deleted = { enabled = true, icon = "-" },
      },
    },
  },
}
