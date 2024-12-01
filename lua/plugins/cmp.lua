return {
  "iguanacucumber/magazine.nvim",
  name = "nvim-cmp", -- Otherwise highlighting gets messed up
  -- "hrsh7th/nvim-cmp",
  -- event = 'VeryLazy',
  dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-emoji",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      preselect = cmp.PreselectMode.None,
      mapping = {
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "cmdline" },
        { name = "emoji" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
