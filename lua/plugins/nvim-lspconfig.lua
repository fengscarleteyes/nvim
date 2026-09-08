vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

vim.g.lazydev_enabled = true

vim.pack.add({
  { src = "https://github.com/folke/lazydev.nvim" },
})

local lsp_configs = {
  {
    filetype = "lua",
    lsp = "lua_ls",
    extra = function()
      require("lazydev").setup({
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          "lazy.nvim",
          vim.env.VIMRUNTIME,
          vim.env.VIMRUNTIME .. "/lua",
          vim.env.VIMRUNTIME .. "/lua/vim",
          vim.env.VIMRUNTIME .. "/lua/vim/lsp",
        },
      })
    end,
  },
  {
    filetype = "markdown",
    lsp = "panache",
  },
}

for _, cfg in ipairs(lsp_configs) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = cfg.filetype,
    callback = function()
      vim.lsp.enable(cfg.lsp)
      if cfg.extra then
        cfg.extra()
      end
    end,
  })
end

-- 在 LSP 客户端 attach 时启用自动补全
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- tab 补全触发
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end
  return "<Tab>"
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  return "<S-Tab>"
end, { expr = true })
