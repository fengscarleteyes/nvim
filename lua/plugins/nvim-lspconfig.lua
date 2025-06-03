-- https://github.com/neovim/nvim-lspconfig

local function enable_lsp_server(path)
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
      vim.lsp.enable(server_name)
    end
  end
end

enable_lsp_server(vim.fn.stdpath("config") .. "/lsp")

return {
  "neovim/nvim-lspconfig",
  dependencies = "folke/lazydev.nvim",
  event = "BufEnter",
}
