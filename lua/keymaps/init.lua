-- local keymaps = {
--     { "<C-]>",     mode = { "i" }, function() require("fittencode").accept_all_suggestions() end, desc = "Fittencode accept all suggestions" },
--     { "<C-e>",     mode = { "i" }, function() require("fittencode").dismiss_suggestions()    end, desc = "Fittencode dismiss suggestions"    },
--     { "<C-Right>", mode = { "i" }, function() require("fittencode").accept_word()            end, desc = "Fittencode accept word"            },
--     { "<C-Down>",  mode = { "i" }, function() require("fittencode").accept_line()            end, desc = "Fittencode accept libe"            },
--     { "<C-Left>",  mode = { "i" }, function() require("fittencode").revoke_word()            end, desc = "Fittencode revoke word"            },
--     { "<C-Up>",    mode = { "i" }, function() require("fittencode").revoke_line()            end, desc = "Fittencode revoke libe"            },
--     { "<leader>fe", mode = { "n"      }, "<cmd>Neotree filesystem toggle<CR>",           desc = "Filesystem neotree" },
-- }

vim.keymap.set(
    "n",
    "<leader>fe",
    "<cmd>Neotree filesystem toggle<CR>",
    {
        noremap	= true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
        silent = true, -- 是否静默执行（不显示命令）
        nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
        expr = false, -- 是否将 rhs 视为表达式（VimScript）
        desc = "Neotree" --映射的描述（显示在 :which-key 等插件中）})
    }
)

return {}