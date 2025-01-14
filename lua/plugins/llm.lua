local function config_online_deepseek()
  require("llm").setup({
    url = "https://api.deepseek.com/chat/completions",
    model = "deepseek-chat",
    api_type = "openai",
    fetch_key = function()
      return "sk-9a7aa1e7ade14eb5806f5604c5a7ffac"
    end,
    temperature = 0.3,
    top_p = 0.7,
    -- chat_ui_opts = {
    --   relative = "editor",
    --   position = "50%",
    --   size = {
    --     width = "95%",
    --     height = "95%",
    --   },
    -- },
    prompt = "You are a helpful chinese assistant.",
    prefix = {
      user = { text = "💭 ", hl = "Title" },
      assistant = { text = "🗨️ ", hl = "Added" },
    },
    history_path = vim.fn.stdpath("config") .. "/llm-history",
    save_session = true,
    max_history = 15,
    max_history_name_length = 20,
    keys = {
      -- The keyboard mapping for the input window.
      ["Input:Submit"] = { mode = "i", key = "<c-s>" },
      ["Input:Cancel"] = { mode = { "n", "i" }, key = "<C-c>" },
      ["Input:Resend"] = { mode = { "n", "i" }, key = "<C-r>" },
      -- only works when "save_session = true"
      ["Input:HistoryNext"] = { mode = { "n", "i" }, key = "<C-j>" },
      ["Input:HistoryPrev"] = { mode = { "n", "i" }, key = "<C-k>" },
      -- The keyboard mapping for the output window in "split" style.
      ["Output:Ask"] = { mode = "n", key = "i" },
      ["Output:Cancel"] = { mode = "n", key = "<C-c>" },
      ["Output:Resend"] = { mode = "n", key = "<C-r>" },
      -- The keyboard mapping for the output and input windows in "float" style.
      ["Session:Toggle"] = { mode = "n", key = "<leader>ac" },
      ["Session:Close"] = { mode = "n", key = { "<esc>", "Q" } },
    },
  })
end

return {
  {
    "Kurama622/llm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    cmd = { "LLMSesionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
    config = config_online_deepseek,
    keys = {
      { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
      { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
      { "<leader>at", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
    },
  },
}
