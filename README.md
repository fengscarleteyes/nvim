# README

- Install

```shell
git clone git@github.com:fengscarleteyes/nvim.git
```

```shell
# 只克隆 vim_pack 一个分支（不拉其余分支的历史）
git clone --branch vim_pack --single-branch git@github.com:fengscarleteyes/nvim.git

# 直连 GitHub 被重置时改用 Gitee 镜像（同样含 vim_pack 分支）
git clone --branch vim_pack --single-branch https://gitee.com/fengscarleteyes/nvim.git
```

```shell
# 格式化当前目录及其所有子文件夹
stylua .

# 格式化指定的项目目录
stylua D:\my_lua_project\src

# 仅格式化 .lua 文件（排除其他后缀）
stylua --glob **/*.lua -- .

# 格式化 .lua 文件，但排除所有 .spec.lua 测试文件
stylua -g *.lua -g !*.spec.lua -- .

# 检查当前目录下哪些文件不符合规范
stylua --check .
```

## version manager

> <https://github.com/y3owk1n/nvs>

## Python

### VENV

```bash
uv venv .venv --python 3.15
source .venv/bin/activate
```

## Usage

```lua
vim.keymap.set({mode}, {lhs}, {rhs}, {opts})

string/table     模式，如 "n"（普通模式）、"i"（插入模式）、"v"（可视模式），或组合 {"n", "v"}
lhs    string    左边按键（触发映射的按键组合），如 "<leader>ff"
rhs    string/function    右边内容，可以是字符串（如 ":echo 'Hello'<CR>"）或 Lua 函数
opts   table    可选参数（见下方）

opts 可选参数：
noremap   boolean    true    是否禁用递归映射（推荐设为 true，避免无限循环）
silent    boolean    false    是否静默执行（不显示命令）
nowait    boolean    false    是否立即应用映射，不等待可能的更长匹配
expr      boolean    false    是否将 rhs 视为表达式（VimScript）
desc      string    nil      映射的描述（显示在 :which-key 等插件中）
```

```lua
vim.o     -- 全局选项 (global)    影响所有窗口和缓冲区的全局设置
vim.wo    -- 窗口局部选项 (window)    只对当前窗口有效的设置
vim.bo    -- 缓冲区局部选项 (buffer)    只对当前缓冲区有效的设置
vim.go    -- 全局选项 (等同于 vim.o)    与 vim.o 相同，为了与 Vimscript 的 :setglobal 保持一致
vim.opt   -- 智能选项设置    根据选项类型自动判断作用域，推荐新用户使用
```

```lua
-- 基本折叠快捷键
zc    -- 关闭当前折叠 (Close fold)
zo    -- 打开当前折叠 (Open fold)
za    -- 切换当前折叠状态 (Toggle fold)
zR    -- 打开所有折叠 (Recursively open all folds)
zM    -- 关闭所有折叠 (Recursively close all folds)
zC    -- 递归关闭当前折叠 (Close fold recursively)
zO    -- 递归打开当前折叠 (Open fold recursively)
zi    -- 全局切换折叠功能 (Toggle folding enable/disable)
```

  | line(bar)                        | comment            |
  | -------------------------------- | ------------------ |
  | Tabline（顶部）                  | ← 类似浏览器标签页 |
  | Winbar（每个窗口顶部，默认隐藏） | ← Neovim 0.8+ 新增 |
  | Buffer 内容区域                  | no bar             |
  | Statusline（底部）               | ← 最经典的 bar     |

## Review workflow

键位：`<leader>` = 空格；想查全部键位用 `<leader>fk`（FzfLua keymaps）。

定义位置：选择器与 diffview 在 `lua/keymaps/git.lua`，gitsigns 的显示配置在
`lua/plugins/gitsigns.lua`。

```lua
-- 选择器（fzf-lua，全部是内置 provider，不需要额外插件）
<leader>gs     -- 工作区的改动文件列表
<leader>gb     -- 当前文件的提交历史
<leader>gc     -- 整个仓库的提交历史
<leader>gd     -- 改动的 diff 视图
<leader>gF     -- 只列 git 跟踪的文件
<leader>gB     -- 分支列表 / 切换

-- 全局对比（diffview：一次看完本次改动涉及的所有文件）
<leader>dv     -- 打开（左侧改动文件树 + 右侧并排 diff）
<leader>dt     -- 打开 / 关闭切换
<leader>dc     -- 关闭
<leader>dh     -- 当前文件的提交历史

-- 逐块处置：gitsigns 有意不绑键位，直接用命令
-- （40 个子命令可 :Gitsigns <Tab> 补全；标志用双横线）
:Gitsigns nav_hunk next --target=all   -- 下一个改动；--target=all 才会扫到已暂存的
:Gitsigns nav_hunk prev --target=all   -- 上一个改动
:Gitsigns stage_hunk                   -- 暂存本块（在已暂存的记号上执行 = 取消暂存）
:Gitsigns reset_hunk                   -- 退回（丢弃）本块
:Gitsigns stage_buffer                 -- 暂存整个文件
:Gitsigns reset_buffer                 -- 退回整个文件
:Gitsigns reset_buffer_index           -- 整个文件取消暂存（真的对文件跑 git reset）
:Gitsigns preview_hunk                 -- 浮窗预览本块改动
:Gitsigns diffthis                     -- 本块与本块基线对比
:Gitsigns blame_line --full            -- 本行 blame
:Gitsigns setqflist attached --open    -- 本文件改动 → quickfix
:Gitsigns toggle_word_diff             -- 词级差异开关
:Gitsigns toggle_current_line_blame    -- 本行 blame 开关
```

## TODO

- tabline add extend callback statusline add
- hop
