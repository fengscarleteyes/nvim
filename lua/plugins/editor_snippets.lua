local snippets_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets")

return {
  "garymjr/nvim-snippets",
  opts = {
    search_paths = { snippets_dir },
    create_cmp_source = true,
  },
}
