vim.pack.add({
    'https://github.com/brianhuster/live-preview.nvim',
    "https://github.com/ibhagwan/fzf-lua"
})
vim.o.autowriteall = true
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged', 'TextChangedP' }, {
    pattern = '*', callback = function()
        vim.cmd('silent! write')
    end
})

-- :LivePreview start test/doc.md
-- :LivePreview close
-- :LivePreview pick
-- :LivePreview help