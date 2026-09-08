vim.pack.add({
    'https://github.com/tris203/precognition.nvim',
})
require('precognition').setup({    disabled_fts = {
      "startify",
      "dashboard",
    }})