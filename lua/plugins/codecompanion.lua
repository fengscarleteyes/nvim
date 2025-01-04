return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- Optional
    {
      "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
      opts = {
        input = {
          enabled = false,
        },
      },
    },
  },
  opts = {
    language = "Chinese",
    adapters = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "https://localhost:11434",
            api_key = "NONE",
          },
          headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer NONE",
            -- ["Authorization"] = "Bearer ${api_key}",
          },
          parameters = {
            sync = true,
          },
          schema = {
            model = {
              default = "qwen2.5-coder:3b",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
      agent = {
        adapter = "ollama",
      },
    },
    -- server = {
    --   url = "127.0.0.1:11434/api/chat",
    -- },
    -- model = "qwen2.5-coder:3b",
  },
}
