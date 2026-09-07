vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
  },
  -- dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  -- optional, but recommended
  "https://github.com/nvim-tree/nvim-web-devicons",
})

require("neo-tree").setup({
  source_selector = {
    winbar = false,
    statusline = false,
  },
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
})

-- vim.pack.add({ "https://github.com/Crysthamus/nvim-file-operations","https://github.com/nvim-neo-tree/neo-tree.nvim" })

-- require("nvim-file-operations").setup()

-- vim.lsp.config("*", {
--   capabilities = require("nvim-file-operations.config").default_capabilities(),
-- })