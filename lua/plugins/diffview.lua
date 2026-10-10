vim.pack.add({
  "https://github.com/sindrets/diffview.nvim",
})

require("diffview").setup({})

-- 审查动线的主入口：gitsigns 只能在单个文件里标 hunk，diffview 负责
-- 「一次看完这次改动涉及的所有文件」——左侧改动文件树 + 右侧并排 diff。
vim.keymap.set(
  "n",
  "<leader>dv",
  "<Cmd>DiffviewOpen<CR>",
  { silent = true, desc = "Diffview: 打开（工作区全部改动）" }
)
vim.keymap.set("n", "<leader>dc", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "Diffview: 关闭" })
vim.keymap.set("n", "<leader>dh", "<Cmd>DiffviewFileHistory %<CR>", {
  silent = true,
  desc = "Diffview: 当前文件的提交历史",
})
