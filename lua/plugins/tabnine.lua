-- https://github.com/codota/tabnine-nvim
-- Windows
-- The build script needs a set execution policy. Here is an example on how to set it
-- Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

-- Get platform dependant build script
local function tabnine_build_path()
  -- Replace vim.uv with vim.loop if using NVIM 0.9.0 or below
  if vim.uv.os_uname().sysname == "Windows_NT" then
    return "pwsh.exe -file .\\dl_binaries.ps1"
  else
    return "./dl_binaries.sh"
  end
end

return {
  "codota/tabnine-nvim",
  -- enabled = false,
  build = tabnine_build_path(),
  opts = {
    max_lines = 1000,
    max_num_results = 3,
    codelens_color = { gui = "#00FF00", cterm = 244 },
    codelens_enabled = true,
    sort = true,
    disable_auto_comment = true,
    accept_keymap = "<C-]>",
    dismiss_keymap = "<C-[>",
    debounce_ms = 800,
    suggestion_color = { gui = "#00FF00", cterm = 244 },
    exclude_filetypes = { "TelescopePrompt", "NvimTree" },
    log_file_path = nil, -- absolute path to Tabnine log file
    ignore_certificate_errors = false,
  },
  config = function(_, opts)
    require("tabnine").setup(opts)
  end,
}

-- api.nvim_set_keymap("x", "<leader>q", "", { noremap = true, callback = require("tabnine.chat").open })
-- api.nvim_set_keymap("i", "<leader>q", "", { noremap = true, callback = require("tabnine.chat").open })
-- api.nvim_set_keymap("n", "<leader>q", "", { noremap = true, callback = require("tabnine.chat").open })
