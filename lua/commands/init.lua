local function remove_state_dir()
  local state_dir = vim.fn.stdpath("state")
  if vim.fn.isdirectory(state_dir) == 1 then
    vim.fn.delete(state_dir, "rf")
  end
end

vim.api.nvim_create_user_command(
  "RemoveStateDir", -- command name
  function()
    vim.ui.input(
      { prompt = 'RemoveStateDir Enter "Y/y" or "N/n": ' }, -- opts
      function(input) -- comfirm
        if string.lower(input) == "y" then
          remove_state_dir()
          vim.cmd("qall!") -- 强制退出（不保存）
        end
      end
    )
  end,
  { desc = "clean nvim state directory" }
)

local function remove_shada_dir()
  local state_dir = vim.fn.stdpath("state")
  local shada_dir = state_dir .. "/shada" -- windows
  if vim.fn.isdirectory(shada_dir) == 1 then
    vim.fn.delete(shada_dir, "rf")
  end
end

vim.api.nvim_create_user_command(
  "RemoveShadaDir", -- command name
  function()
    vim.ui.input(
      { prompt = 'RemoveShadaDir Enter "Y/y" or "N/n": ' }, -- opts
      function(input) -- comfirm
        if string.lower(input) == "y" then
          remove_shada_dir()
          vim.cmd("qall!") -- 强制退出（不保存）
        end
      end
    )
  end,
  { desc = "clean nvim shada directory" }
)

-- 复制后高亮复制的文本
vim.api.nvim_create_autocmd(
  "TextYankPost", -- command name
  {
    group = vim.api.nvim_create_augroup("highlight_yank", {}),
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 2000 })
    end,
  }
)
