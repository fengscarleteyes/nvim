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
