-- https://github.com/neovim/nvim-lspconfig

local function enable_lsp_server(path)
  local handle = vim.uv.fs_scandir(path)
  if not handle then
    return
  end

  while true do
    local name, _ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    if name:match("%.lua$") then
      local module_name = name:gsub(".lua$", "")
      vim.lsp.enable(module_name)
    end
  end
end

enable_lsp_server(vim.fn.stdpath("config") .. "/lsp")

return {
  "neovim/nvim-lspconfig",
  dependencies = "folke/lazydev.nvim",
  event = "BufEnter",
}
