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

-- 浮动终端窗口
local floatterm = require("custom.floatterm")

-- 绑定快捷键（Ctrl+\ 切换浮动终端）
vim.keymap.set("n", "<C-\\>", function()
  floatterm.toggle()
end, { desc = "Toggle floating terminal" })

vim.keymap.set("t", "<C-\\>", function()
  floatterm.toggle()
end, { desc = "Toggle floating terminal" })

-- 终端模式下按 Esc 直接关闭浮动终端
vim.keymap.set("t", "<Esc>", function()
  floatterm.close()
end, { desc = "Close floating terminal" })

-- auto pairs
local autopair = require("custom.autopair")
autopair.enable()
-- API：
--   autopair.is_enabled()                  是否启用
--   autopair.enable() / disable() / toggle()
--   autopair.add_pair(open, close)         新增/覆盖一个配对并即时生效
--   autopair.remove_pair(open)             移除一个配对并即时生效
--   autopair.jump_outer_start()            跳到外部开头（开括号左侧）
--   autopair.jump_inner_middle()           跳到内部中间
--   autopair.jump_outer_end()              跳到外部结束（闭括号右侧）
--   autopair.jump(which)                   通用跳转 which 同上三者之一
--   autopair.map_jump(name, keys)          自定义跳转键；keys=false 卸载

-- 诊断高亮 + 诊断提醒（纯副作用，无导出接口）
require("custom.diagnostics")
