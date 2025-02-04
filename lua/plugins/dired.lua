vim.g.dired = {
  show_hidden = true,
  -- keymaps = {
  --   up = { i = "<C-p>", n = "k" },
  --   down = "j", -- just normal mode
  -- available actions
  -- open | down | up | quite | create_file | create_dir
  -- delete | rename | copy | cut | paste | toggle_hidden
  -- },
}

return {
  "nvimdev/dired.nvim",
  -- enabled = false,
}

-- C-N in insert and normal move donw
-- C-P in insert and normal move up
-- j/k in normal mode same as C-N/C-P
-- q quite in normal mode
-- C-C quite in insert mode
-- <CR> open
-- u go up
-- cf create file
-- cd create dir
-- D delete file/dir
-- R rename
-- yy copy
-- p paste and cut move
-- gh toggle show hidden files
-- dd cut
