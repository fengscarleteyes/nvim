-- -- https://github.com/nvim-treesitter/nvim-treesitter

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate'
}
-- require'nvim-treesitter'.install { 'rust', 'javascript', 'zig' }
-- require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000) -- wait max. 5 minutes
