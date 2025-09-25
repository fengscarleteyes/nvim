-- https://github.com/piersolenski/import.nvim

-- TODO: test

return -- Lazy
{
  "piersolenski/import.nvim",
  enabled = false,
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  opts = {
    picker = "fzf-lua",
  },
  -- keys = {
  --   {
  --     "<leader>i",
  --     function()
  --       require("import").pick()
  --     end,
  --     desc = "Import",
  --   },
  -- },
}
