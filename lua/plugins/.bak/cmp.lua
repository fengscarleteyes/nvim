return {
  "iguanacucumber/magazine.nvim",
  name = "nvim-cmp", -- Otherwise highlighting gets messed up
  enabled = false,
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
    -- `/` cmdline setup.
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" },
          },
        },
      }),
    })
    -- cmp.setup({
    --   mapping = {
    --     ["<C-CR>"] = cmp.mapping.close(),
    --     ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    --     ["<Tab>"] = cmp.mapping.select_next_item(),
    --     ["<CR>"] = cmp.mapping.confirm({
    --       behavior = cmp.ConfirmBehavior.Insert,
    --       select = true,
    --     }),
    --     -- Accept multi-line completion
    --     ["<c-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
    --   },
    --   sources = cmp.config.sources({
    --     { name = "fittencode", group_index = 1 },
    --     { name = "nvim_lsp" },
    --     { name = "path" },
    --     { name = "emoji" },
    --     { name = "snippets" },
    --   }, {
    --     { name = "buffer" },
    --   }),
    -- })
  end,
}
