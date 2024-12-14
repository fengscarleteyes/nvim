return {
  "garymjr/nvim-snippets",
  opts = {
    search_paths = { vim.fn.stdpath("config") .. "/snippets" },
    create_cmp_source = true,
  },
}
