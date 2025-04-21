-- https://github.com/milanglacier/minuet-ai.nvim

return {
  "milanglacier/minuet-ai.nvim",
  config = function()
    require("minuet").setup({
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          end_point = "https://api.deepseek.com/v1/chat/completions",
          api_key = "sk-9a7aa1e7ade14eb5806f5604c5a7ffac",
          name = "deepseek",
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },

      virtualtext = {
        auto_trigger_ft = {},
        keymap = {
          -- accept whole completion
          accept = "<A-A>",
          -- accept one line
          accept_line = "<A-a>",
          -- accept n lines (prompts for number)
          -- e.g. "A-z 2 CR" will accept 2 lines
          accept_n_lines = "<A-z>",
          -- Cycle to prev completion item, or manually invoke completion
          prev = "<A-[>",
          -- Cycle to next completion item, or manually invoke completion
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },
    })
  end,

  dependencies = { "nvim-lua/plenary.nvim", "Saghen/blink.cmp" },
}

-- TODO: ...
