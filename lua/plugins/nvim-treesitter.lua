vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

-- 安装 parser 时优先用 git clone
require("nvim-treesitter.install").prefer_git = true

-- 使用 zig 编译 parser
require("nvim-treesitter.install").compilers = { "zig" }
local ts_langs = {
  "lua",
  "python",
  "json",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "vim",
  "vimdoc",
  "rust",
}

require("nvim-treesitter").setup({
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath("data") .. "/site",
  ensure_installed = ts_langs,
  auto_install = true,
  sync_install = false,
})

-- require('nvim-treesitter').install (ts_langs)
-- require('nvim-treesitter').install (ts_langs):wait(300000)

-- parser 还没装好的语言（例如 toml / json / yaml / python）在这里会抛错，
-- 并连带让 :edit 打开该文件失败，所以用 pcall 兜住，出错只提醒一次。
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_langs,
  callback = function()
    local ok, err = pcall(vim.treesitter.start)
    if not ok then
      vim.notify_once(
        ("treesitter: %s 的 parser 不可用，已跳过语法高亮：%s"):format(vim.bo.filetype, err),
        vim.log.levels.WARN
      )
    end
  end,
})

-- 折叠：基于 treesitter 的表达式折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 999
vim.opt.foldenable = true
-- vim.opt.foldcolumn = '1'  -- 在侧边栏显示折叠指示器
vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
