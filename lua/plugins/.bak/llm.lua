-- https://github.com/Kurama622/llm.nvim

return   {
    "Kurama622/llm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim"},
    cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
    config = function()
      require("llm").setup({
      url = "https://api.deepseek.com/chat/completions",
      model = "deepseek-chat",
        api_type = "openai",
      max_tokens = 4096,
      temperature = 0.3,
      top_p = 0.7,
      fetch_key = function()
        return "sk-9a7aa1e7ade14eb5806f5604c5a7ffac"
      end,
      })
    end,
    keys = {
      { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
    },
  }



-- {
--   "Kurama622/llm.nvim",
--   dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
--   cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
--   config = function()
--     require("llm").setup({
--       url = "https://api.deepseek.com/chat/completions",
--       model = "deepseek-chat",
--       api_type = "openai",
--       max_tokens = 4096,
--       temperature = 0.3,
--       top_p = 0.7,
--       fetch_key = function()
--         return "sk-9a7aa1e7ade14eb5806f5604c5a7ffac"
--       end,
--       prompt = "You are a helpful chinese assistant.",
--       prefix = {
--         user = { text = "💭 ", hl = "Title" },
--         assistant = { text = "🗨️ ", hl = "Added" },
--       },
--       history_path = vim.fn.stdpath("config") .. "/history" .. "/llm",
--       save_session = true,
--       max_history = 15,
--       max_history_name_length = 20,

--       auto_trigger = true,
--       style = "virtual_text",
--       Completion = {
--         opts = {
--           keymap = {
--             virtual_text = {
--               accept = {
--                 mode = "i",
--                 keys = "<A-a>",
--               },
--               next = {
--                 mode = "i",
--                 keys = "<A-n>",
--               },
--               prev = {
--                 mode = "i",
--                 keys = "<A-p>",
--               },
--               toggle = {
--                 mode = "n",
--                 keys = "<leader>cp",
--               },
--             },
--           },
--         },
--       },

--       -- stylua: ignore
--       keys = {
--         -- The keyboard mapping for the input window.
--         ["Input:Submit"]      = { mode = "n", key = "<cr>" },
--         ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
--         ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },

--         -- only works when "save_session = true"
--         ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
--         ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },

--         -- The keyboard mapping for the output window in "split" style.
--         ["Output:Ask"]        = { mode = "n", key = "i" },
--         ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
--         ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

--         -- The keyboard mapping for the output and input windows in "float" style.
--         ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
--         ["Session:Close"]     = { mode = "n", key = {"<esc>", "Q"} },

--         -- Scroll
--         ["PageUp"]            = { mode = {"i","n"}, key = "<C-b>" },
--         ["PageDown"]          = { mode = {"i","n"}, key = "<C-f>" },
--         ["HalfPageUp"]        = { mode = {"i","n"}, key = "<C-u>" },
--         ["HalfPageDown"]      = { mode = {"i","n"}, key = "<C-d>" },
--         ["JumpToTop"]         = { mode = "n", key = "gg" },
--         ["JumpToBottom"]      = { mode = "n", key = "G" },
--       },
--     })

--     vim.api.nvim_create_autocmd({ "VimEnter" }, {
--       callback = function()
--         vim.api.nvim_command("LLMAppHandler Completion")
--       end,
--     })
--   end,
--   -- in lua\keymaps\leader_a.lua
--   -- keys = {
--   --   { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
--   --   { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
--   --   { "<leader>ts", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
--   -- },
-- }
