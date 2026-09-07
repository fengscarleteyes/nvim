vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

vim.g.lazydev_enabled = true

vim.pack.add({
  { src = "https://github.com/folke/lazydev.nvim" },
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.lua",
  callback = function()
    -- 打开 .lua 文件时执行
    vim.lsp.enable("lua_ls")
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
})

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
