-- https://github.com/bassamsdata/namu.nvim


-- TODO: test
return {
    "bassamsdata/namu.nvim",
    -- enabled = false,
    config = function()
      require("namu").setup({
        -- Enable the modules you want
        namu_symbols = {
          enable = true,
          options = {}, -- here you can configure namu
        },
        -- Optional: Enable other modules if needed
        ui_select = { enable = false }, -- vim.ui.select() wrapper
      })
      -- === Suggested Keymaps: ===
      vim.keymap.set("n", "<leader>ss",":Namu symbols<cr>" , {
        desc = "Jump to LSP symbol",
        silent = true,
      })
      vim.keymap.set("n", "<leader>sw", ":Namu workspace<cr>", {
        desc = "LSP Symbols - Workspace",
        silent = true,
      })
    end,
  }
--   <CR>	选择项目
--   <Esc>	关闭选取器
--   <C-n>	下一项
--   <C-p>	上一项
--   <Tab>	切换多选
--   <C-a>	全选
--   <C-l>	全部清除
--   <C-y>	猛拉符号
--   <C-d>	删除元件
--   <C-v>	垂直分割中打开元件
--   <C-h>	在水平分割中打开元件
--   <C-o>	向 CodeCompanion 聊天添加符号