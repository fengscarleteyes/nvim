-- stylua: ignore start
return {
  { "<leader>a", group = "Ai" },
  { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
  { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
  { "<leader>at", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
}
-- stylua: ignore end
