vim.pack.add({
  "https://github.com/dlyongemallo/diffview-plus.nvim",
})

-- 键位集中在 lua/keymaps/git.lua（<leader>d*）。
-- 这是 sindrets/diffview.nvim 的维护版 fork：Lua 模块名仍是 `diffview`，
-- `:DiffviewOpen` / `:DiffviewClose` / `:DiffviewFileHistory` 也都保留，
-- 所以配置与键位无需改动（它自己的两条破坏性变更见 :h diffview.changelog，
-- 只影响显式设过 file_panel.show / log_options 的人，本文件是空配置）。
require("diffview").setup({})
