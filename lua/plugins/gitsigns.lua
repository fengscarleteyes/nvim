vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

-- 只保留显示相关配置：键位按约定集中在 lua/keymaps/git.lua（那里监听 gitsigns 的
-- `User GitSignsUpdate` 事件做 buffer 局部绑定，效果与写在这里的 on_attach 一致）。
-- word_diff：审查 AI 改动用 —— 一行里只换了个 token 时才看得出改在哪个词。
require("gitsigns").setup({
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})
