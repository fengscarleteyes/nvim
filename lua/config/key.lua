-- Example
-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover) -- hover
-- vim.keymap.set('n', '<M-Tab>', function () vim.cmd('NeoTermToggle') end)
-- vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermEnterNormal') end)

-- vim.keymap.set("n", "<F7>", vim.lsp.buf.hover)

-- stylua: ignore
-- vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-;>", function()
--   return vim.fn["codeium#CycleCompletions"](1)
-- end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-,>", function()
--   return vim.fn["codeium#CycleCompletions"](-1)
-- end, { expr = true, silent = true })
-- vim.keymap.set("i", "<c-x>", function()
--   return vim.fn["codeium#Clear"]()
-- end, { expr = true, silent = true })