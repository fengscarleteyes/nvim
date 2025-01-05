return {
  "aaronik/treewalker.nvim",
  opts = {
    highlight = true,
    highlight_duration = 250,
    highlight_group = "CursorLine",
  },
}
--
-- -- movement
-- vim.keymap.set({ 'n', 'v' }, '<C-k>', '<cmd>Treewalker Up<cr>', { silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<C-j>', '<cmd>Treewalker Down<cr>', { silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<C-l>', '<cmd>Treewalker Right<cr>', { silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<C-h>', '<cmd>Treewalker Left<cr>', { silent = true })
--
-- -- swapping
-- vim.keymap.set('n', '<C-S-j>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
-- vim.keymap.set('n', '<C-S-k>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
-- vim.keymap.set('n', '<C-S-l>', '<cmd>Treewalker SwapRight<CR>', { silent = true })
-- vim.keymap.set('n', '<C-S-h>', '<cmd>Treewalker SwapLeft<CR>', { silent = true })
