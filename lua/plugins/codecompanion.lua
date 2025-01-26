return {
  "olimorris/codecompanion.nvim",
  -- enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      opts = {
        system_prompt = function()
          return "You are a helpful chinese assistant."
        end,
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://api.deepseek.com",
              api_key = "sk-9a7aa1e7ade14eb5806f5604c5a7ffac",
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "deepseek" },
        inline = { adapter = "deepseek" },
        agent = { adapter = "deepseek" },
      },
    })
  end,
}
