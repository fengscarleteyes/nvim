vim.pack.add({
  "https://github.com/m4xshen/hardtime.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
})

require("hardtime").setup({
  -- dashboard（lua/custom/dashboard.lua 的启动看板）是只读的静态面板：上面没有可导航的内容，
  -- 在它里面按 h/j/k/l 属于「看错缓冲区」而不是坏习惯，所以按 filetype 关掉拦截 / 提示
  -- （vim.tbl_deep_extend 合并，默认表里的 alpha / snacks_dashboard / lazy 等仍然有效）。
  -- 注意：本模块默认的快捷功能里有 h 键（:FzfLua oldfiles），不加这条时第 4 次连按会被 hardtime 拦掉。
  disabled_filetypes = { dashboard = true },
})
