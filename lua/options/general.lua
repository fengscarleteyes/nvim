-- ============================================================
-- 基础设置：启动提示、更新时间、编码、项目根目录、剪贴板、外部 provider
-- （由 lua/options.lua 通过 :runtime! lua/options/*.lua 加载）
-- ============================================================

-- 禁用启动时的版本提示
vim.opt.shortmess:append("I")

-- Neovim default updatetime is 4000
vim.opt.updatetime = 200

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "ucs-bom,utf-8,default,latin1"

vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- vim.opt.autowrite = true -- Enable auto write
-- vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard

-- disable check warn
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
