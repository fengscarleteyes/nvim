vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

local function enable_lsp_server(path)
  local lsp_server_table = {}
  local handle = vim.uv.fs_scandir(path)
  if not handle then
    return
  end

  while true do
    local file_name, _ = vim.uv.fs_scandir_next(handle)
    if not file_name then
      break
    end
    if file_name:match("%.lua$") then
      local server_name = file_name:gsub(".lua$", "")
      table.insert(lsp_server_table, server_name)
    end
  end
  vim.lsp.enable(lsp_server_table)
end

enable_lsp_server(vim.fn.stdpath("config") .. "/lsp")

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
