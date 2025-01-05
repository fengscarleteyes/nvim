-- https://github.com/Kurama622/llm.nvim/issues/12

local function local_llm_streaming_handler(chunk, line, assistant_output, bufnr, winid, F)
  if not chunk then
    return assistant_output
  end
  local tail = chunk:sub(-1, -1)
  if tail:sub(1, 1) ~= "}" then
    line = line .. chunk
  else
    line = line .. chunk
    local status, data = pcall(vim.fn.json_decode, line)
    if not status or not data.message.content then
      return assistant_output
    end
    assistant_output = assistant_output .. data.message.content
    F.WriteContent(bufnr, winid, data.message.content)
    line = ""
  end
  return assistant_output
end

local function local_llm_parse_handler(chunk)
  local assistant_output = chunk.message.content
  return assistant_output
end

return {
  {
    "Kurama622/llm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    cmd = { "LLMSesionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
    config = function()
      local tools = require("llm.common.tools")
      require("llm").setup({
        -- [[ local llm ]]
        url = "http://localhost:11434/api/chat",
        model = "qwen2.5-coder:3b",
        fetch_key = function()
          return "NONE"
        end,
        api_type = "ollama",
        temperature = 0.3,
        top_p = 0.7,
        prompt = "You are a helpful chinese assistant.",
        prefix = {
          user = { text = "😃 ", hl = "Title" },
          assistant = { text = "  ", hl = "Added" },
        },
        history_path = vim.fn.stdpath("config") .. "/llm-history",
        save_session = true,
        max_history = 15,
        max_history_name_length = 20,
        streaming_handler = local_llm_streaming_handler,
        parse_handler = local_llm_parse_handler,
        app_handler = {
          OptimizeCode = {
            handler = tools.side_by_side_handler,
          },
          TestCode = {
            handler = tools.side_by_side_handler,
            prompt = [[ Write some test cases for the following code, only return the test cases.
                        Give the code content directly, do not use code blocks or other tags to wrap it. ]],
            opts = {
              right = {
                title = " Test Cases ",
              },
            },
          },
          Translate = {
            handler = tools.qa_handler,
          },
          OptimCompare = {
            handler = tools.action_handler,
          },
          WordTranslate = {
            handler = tools.flexi_handler,
            prompt = "Translate the following text to Chinese, please only return the translation",
            opts = {
              exit_on_move = true,
              enter_flexible_window = false,
            },
          },
          CodeExplain = {
            handler = tools.flexi_handler,
            prompt = "Explain the following code, please only return the explanation, and answer in Chinese",
            opts = {
              enter_flexible_window = true,
            },
          },
        },
        -- stylua: ignore
        keys = {
          -- The keyboard mapping for the input window.
          ["Input:Submit"]      = { mode = "i", key = "<c-g>" },
          ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
          ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },
          -- only works when "save_session = true"
          ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
          ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },
          -- The keyboard mapping for the output window in "split" style.
          ["Output:Ask"]        = { mode = "n", key = "i" },
          ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
          ["Output:Resend"]     = { mode = "n", key = "<C-r>" },
          -- The keyboard mapping for the output and input windows in "float" style.
          ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
          ["Session:Close"]     = { mode = "n", key = {"<esc>", "Q"} },
        },
      })
    end,
    keys = {
      { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
      { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
      { "<leader>at", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
    },
  },
}
