-- TODO: add new keymaps ...
---@module "snacks"

local f = require("fittencode")

local function translate_to_chinese()
  Snacks.input({
    icon = " ",
    icon_hl = "SnacksInputIcon",
    icon_pos = "left",
    prompt_pos = "title",
    win = { style = "input" },
    expand = true,
  }, function(value)
    f.translate_text({ content = value, target_language = "Chinese" })
  end)
end

local function translate_to_english()
  Snacks.input({
    icon = " ",
    icon_hl = "SnacksInputIcon",
    icon_pos = "left",
    prompt_pos = "title",
    win = { style = "input" },
    expand = true,
  }, function(value)
    f.translate_text({ content = value, target_language = "English" })
  end)
end

-- stylua: ignore start
return {
  { "<leader>a", group = "Ai" },
  { "<C-]>",      mode = { "i" }, function() f.accept_all_suggestions() end,     desc = "Fittencode accept all suggestions" },
  { "<C-e>",      mode = { "i" }, function() f.dismiss_suggestions()    end,     desc = "Fittencode dismiss suggestions"    },
-- Fitten show_chat  Show chat window
  { "<leader>aa", mode = { "n" }, "<CMD>Fitten start_chat<CR>",                  desc = "Fittencode start chat window"      },
  { "<leader>at", mode = { "n" }, "<CMD>Fitten toggle_chat<CR>",                 desc = "Fittencode toggle chat window"     },
  { "<leader>ac", mode = { "x" }, "<CMD>Fitten translate_text_into_chinese<CR>", desc = "Fittencode translate to CN"        },
  { "<leader>ae", mode = { "x" }, "<CMD>Fitten translate_text_into_english<CR>", desc = "Fittencode translate to EN"        },
  { "<leader>aC", mode = { "n" }, translate_to_chinese,                          desc = "Fittencode translate to CN input"  },
  { "<leader>aE", mode = { "n" }, translate_to_english,                          desc = "Fittencode translate to EN input"  },
}
-- stylua: ignore end
-- TODO: add keymap
-- Fitten document_code  Document code
-- Fitten edit_code  Edit code
-- Fitten explain_code Explain code
-- Fitten find_bugs  Find bugs
-- Fitten generate_unit_test [test_framework] [language] Generate unit test
-- Fitten implement_features Implement features
-- Fitten optimize_code  Optimize code
-- Fitten refactor_code  Refactor code
-- Fitten identify_programming_language  Identify programming language
-- Fitten analyze_data Analyze data
-- login(username, password) Login to Fitten Code AI
-- logout()  Logout from Fitten Code AI
-- register()  Register to Fitten Code AI
-- get_current_status()  Get the StatusCodes of the InlineEngine and ActionEngine
-- triggering_completion() Manually triggering completion
-- has_suggestions() Check if there are suggestions
-- accept_line() Accept line
-- accept_word() Accept word
-- accept_char() Accept character
-- revoke_line() Revoke line
-- revoke_word() Revoke word
-- revoke_char() Revoke character
-- document_code(ActionOptions)  Document code
-- edit_code(ActionOptions)  Edit code
-- explain_code(ActionOptions) Explain code
-- find_bugs(ActionOptions)  Find bugs
-- generate_unit_test(GenerateUnitTestOptions) Generate unit test
-- implement_features(ImplementFeaturesOptions)  Implement features
-- optimize_code(ActionOptions)  Optimize code
-- refactor_code(ActionOptions)  Refactor code
-- identify_programming_language(ActionOptions)  Identify programming language
-- analyze_data(ActionOptions) Analyze data
-- translate_text_into_chinese(TranslateTextOptions) Translate text into Chinese
-- translate_text_into_english(TranslateTextOptions) Translate text into English
-- enable_completions(EnableCompletionsOptions)  Enable completions
