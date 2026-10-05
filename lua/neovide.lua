if vim.g.neovide then
  -- ========== 外观与布局 ==========
  -- vim.o.guifont = "JetBrainsMono Nerd Font:h14" -- 字体（也可在 config.toml 设）
  vim.g.neovide_scale_factor = 1.0 -- 整体缩放比例
  vim.g.neovide_padding_top = 0 -- 顶部内边距（像素）
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  -- ========== 透明度与模糊 ==========
  vim.g.neovide_opacity = 1 -- 整体透明度 0.0 ~ 1.0
  -- vim.g.neovide_opacity = 0.9 -- 整体透明度 0.0 ~ 1.0
  -- 浮动窗口背景模糊半径（需toml配置 no-multigrid = false）
  -- vim.g.neovide_floating_blur_amount_x = 1.0
  -- vim.g.neovide_floating_blur_amount_y = 1.0

  -- ========== 动画与性能 ==========
  vim.g.neovide_refresh_rate = 60 -- 刷新率
  vim.g.neovide_refresh_rate_idle = 5 -- 失焦时的刷新率
  vim.g.neovide_scroll_animation_length = 0.1 -- 滚动动画时长（秒）
  -- vim.g.neovide_no_idle = true                -- 强制持续渲染（与 idle 相反）

  -- ========== 光标设置 ==========
  vim.g.neovide_cursor_animation_length = 0.1 -- 光标移动动画时长
  vim.g.neovide_cursor_trail_size = 0.3 -- 光标拖尾大小 (0.0~1.0)
  vim.g.neovide_cursor_antialiasing = true -- 光标抗锯齿
  -- 光标特效: "", "railgun", "torpedo", "pixiedust", "sonicboom"
  -- vim.g.neovide_cursor_vfx_mode = "railgun"

  -- ========== 输入与交互 ==========
  vim.g.neovide_hide_mouse_when_typing = true -- 打字时隐藏鼠标
  vim.g.neovide_input_macos_alt_is_meta = true -- macOS: 将 Alt 视为 Meta 键
  vim.g.neovide_confirm_quit = true -- 退出时若有未保存更改则确认
end

-- neovide clipboard : <C-r> +
