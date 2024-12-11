return {
  "Exafunction/codeium.nvim",
  cmd = "Codeium",
  build = ":Codeium Auth",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
      enable_chat = true,
      -- enable_chat = false,
      enterprise_mode = false,
      enable_cmp_source = false,
      virtual_text = { enable = true, map_keys = false },
    })
  end,
}
