vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup({
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = true, -- 审查 AI 改动用：一行里只换了个 token 时才看得出改在哪个词
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`

  -- gitsigns 不提供任何默认键位（插件源码 config.lua 里只有 on_attach 钩子，
  -- 注释写明 "Mainly used to setup keymaps"），所以逐块审查、暂存、退回这些
  -- 动作必须自己绑。函数名均取自 gitsigns.actions，setqflist() 无参时作用于
  -- 当前 buffer（源码 actions/qflist.lua:42 `target = target or current_buf()`）。
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    -- 在改动块之间跳
    map("n", "]c", function()
      gs.nav_hunk("next")
    end, "Gitsigns: 下一个改动")
    map("n", "[c", function()
      gs.nav_hunk("prev")
    end, "Gitsigns: 上一个改动")

    -- 逐块处置：暂存 / 退回 / 撤销暂存
    map("n", "<leader>hs", gs.stage_hunk, "Gitsigns: 暂存本块改动")
    map("n", "<leader>hr", gs.reset_hunk, "Gitsigns: 退回本块改动")
    map("n", "<leader>hS", gs.stage_buffer, "Gitsigns: 暂存整个文件")
    map("n", "<leader>hR", gs.reset_buffer, "Gitsigns: 退回整个文件")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Gitsigns: 撤销上次暂存")

    -- 看：浮窗预览 / 整屏对比 / 本行来历
    map("n", "<leader>hp", gs.preview_hunk, "Gitsigns: 预览本块改动")
    map("n", "<leader>hd", gs.diffthis, "Gitsigns: 本块与本块基线对比")
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Gitsigns: 本行 blame")

    -- 把本文件所有改动灌进 quickfix，用 :cnext / :copen 逐条过
    map("n", "<leader>hq", gs.setqflist, "Gitsigns: 改动列表 → quickfix")

    -- 显示开关
    map("n", "<leader>hw", gs.toggle_word_diff, "Gitsigns: 词级差异开关")
    map("n", "<leader>hB", gs.toggle_current_line_blame, "Gitsigns: 本行 blame 开关")
  end,
})
