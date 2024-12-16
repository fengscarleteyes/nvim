-- TODO: add this plugin to the list of plugins
return {
  "hedyhli/outline.nvim",
  enabled = false,
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = { -- Example mapping to toggle outline
    { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  opts = {
    -- Your setup opts here
  },
}
