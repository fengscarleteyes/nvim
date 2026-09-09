vim.pack.add({
  { src = "https://github.com/chrisgrieser/nvim-origami" },
})

require("origami").setup({ foldKeymaps = {
  setup = false,
} })
