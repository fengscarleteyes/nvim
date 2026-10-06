# pi 代理在 neovim 下的工作流

pi（终端 AI 编码代理）与 neovim 并行使用时的日常流程。仓库内的验证命令、提交约定、已知坑不在这里重复，分别见 AGENTS.md 的 §6、§8、§7。

## 环境前提

pi 已装，依赖清单见 DEPENDENCIES.md 的 D 类。neovim ≥ 0.12 加载本仓库配置。pi 跑在一个独立终端，neovim 跑在另一个终端，两个终端都 `cd` 到仓库根目录。不要用 neovim 的 `:terminal` 跑 pi，它的全屏 viewport 和扩展键（`Shift+Enter` 等）会退化。

## 一次闭环

1. 开 pi
2. 下指令
3. 切回 neovim 审查改动
4. 验证
5. 提交

## 启动与恢复会话

| 命令 | 作用 |
| --- | --- |
| `pi` | 在当前目录启动 |
| `pi --continue` | 恢复当前目录最近的会话 |
| `pi --resume` | 打开会话选择器 |
| `/new` | 新建会话 |
| `/name <名称>` | 给会话命名 |
| `/session` | 查看会话文件、消息数、token 用量 |
| `/compact` | 手动压缩上下文 |

## 下指令与 vibekit 流水线

一次只做一件事，动手前先和 pi 确认目标，约定见 AGENTS.md 的 §5。会话内用 `@` 引用文件。

- 有明确方案的复杂改动：`/vibekit:vibe`，走 brainstorm、plan、exec、verify 四步。
- 即兴小改：`/vibekit:quick`，跳过 spec 和 plan 直接改。

## 在 neovim 里审查 pi 的改动

pi 在另一个终端改文件，neovim 不会自动刷新，先 `:checktime` 重新读取磁盘内容。

- gitsigns 逐 hunk 审：`:Gitsigns preview_hunk` 预览，`:Gitsigns stage_hunk` 暂存，`:Gitsigns reset_hunk` 撤销。
- dashboard 按 `g` 打开 lazygit，看整体 diff 并提交。

## 验证与提交

改动落地后按 AGENTS.md 的 §6 自检，提交按 AGENTS.md 的 §8 约定。
