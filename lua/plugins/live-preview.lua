vim.pack.add({
  "https://github.com/brianhuster/live-preview.nvim",
  "https://github.com/ibhagwan/fzf-lua",
})
vim.o.autowriteall = true
-- 只在 markdown 上自动写盘：live-preview 需要文件落盘才能预览，但原先是全局的
-- 每次 TextChanged 都写，副作用是「还没想好的编辑已经进磁盘、:e! 撤不回来」，
-- 而且 CLI agent 正在写同一文件时可能与自动写盘互相覆盖。
-- 若以后要用 live-preview 预览别的格式，把 pattern 一并加上即可。
vim.api.nvim_create_autocmd({ "InsertLeavePre", "TextChanged", "TextChangedP" }, {
  pattern = "*.md",
  callback = function()
    vim.cmd("silent! write")
  end,
})

-- :LivePreview start test/doc.md
-- :LivePreview close
-- :LivePreview pick
-- :LivePreview help
