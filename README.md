# README

- Install

```shell
git clone git@github.com:fengscarleteyes/nvim.git
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

```text
# custom目录添加新文件

## 实现前提

- 实现前 思考功能将实现哪些模块是否必要
- 非必要的部分 或 扩展功能 可抛出选项和描述供我选择是否增加
- 我确认最终实现的目标后 再开始实现代码
- 目的是功能简洁化 以实现基础功能即可

 实现功能如下：

- 提示词模板

1. 智能悬浮提示（Hover Doc）
在浮动窗口中显示光标所在符号的文档信息，支持 Markdown 渲染、代码块高亮和链接跳转。
支持"保持悬浮窗口"模式（:Lspsaga hover_doc ++keep），方便连续查阅。
可通过 CursorHold 自动命令实现输入时自动弹出 hover 文档。
对应命令：:Lspsaga hover_doc
2. 代码动作（Code Action）
弹出代码修复/重构菜单，类似 VS Code 的小灯泡体验，支持数字快捷键快速选择。
支持普通模式下的单行 code action 和可视模式下的范围 code action（:Lspsaga range_code_action）。
可扩展 gitsigns 集成，在行号旁显示代码操作提示。
对应命令：:Lspsaga code_action
3. 诊断信息展示（Diagnostics）
在浮动窗口中展示当前行或光标处的诊断信息（Error/Warn/Info/Hint），支持自定义图标、前缀格式和消息格式。
支持诊断跳转：:Lspsaga diagnostic_jump_next / diagnostic_jump_prev。
可配置是否使用 lspsaga 自带的诊断 sign 图标。
对应命令：:Lspsaga show_line_diagnostics / show_cursor_diagnostics
4. 代码定义预览（Peek Definition）
在不跳转文件的前提下，以浮动窗口预览函数/变量的定义，快速了解代码结构。
对应命令：:Lspsaga peek_definition
5. LSP Finder（异步引用/定义查找）
在一个浮动窗口中同时展示光标符号的定义、引用、实现，支持快速跳转到目标位置。
支持在 finder 窗口中用快捷键分屏/垂直分屏打开目标文件。
对应命令：:Lspsaga lsp_finder / :Lspsaga finder
6. 符号重命名（Rename）
提供交互式重命名浮动窗口，输入新名称后一键应用到所有引用处。
支持将重命名结果输出到 quickfix list，方便批量审查。
对应命令：:Lspsaga rename
7. 签名帮助（Signature Help）
在调用函数时自动显示参数签名提示，支持插入模式下通过 CursorHoldI 自动触发。
对应命令：:Lspsaga signature_help
8. 浮动终端（Float Terminal）
内置可切换的浮动终端窗口，可在 Neovim 内直接执行 shell 命令或打开交互式 shell。
支持自定义启动命令和工作目录。
对应命令：:Lspsaga term_toggle
9. 调用链导航（Call Hierarchy）
查看函数的调用者（incoming calls）和被调用者（outgoing calls），方便梳理代码调用关系。
对应命令：:Lspsaga incoming_calls / outgoing_calls
10. Outline（文档符号大纲）
以树形结构展示当前文件的符号（类、方法、变量等），支持快速跳转。
对应命令：:Lspsaga outline
11. 光束线（Beacon）
在窗口切换或跳转时，用高亮闪烁效果标记光标新位置，方便视觉追踪。

-- custom目录添加新文件
-- 实现前提
-- 实现前 思考功能将实现哪些模块是否必要
-- 非必要的部分 或 扩展功能 可抛出选项和描述供我选择是否增加
-- 我确认最终实现的目标后 再开始实现代码
-- 目的是功能简洁化 以实现基础功能即可
-- 预留配置项
-- disable_filetypes table { "mason", "dashboard" }
-- 功能实现：
-- 当出现诊断信息时 底部自动弹出一个带有边框的窗口 展示简洁的诊断信息
-- 诊断信息 只需要展示 各种诊断级别信息的数量 尽可能简洁
-- 当诊断信息消失时 自动消失
-- 不需要进行鼠标操作
-- 提供命令（如neovim默认有对应功能则使用默认）
  -- 上一条诊断信息 触发跳转到对应行
  -- 下一条诊断信息 触发跳转到对应行
  -- 复制当前行诊断信息到剪贴板
  -- 复制所有诊断信息到剪贴板
-- 默认不启用快捷键 提供默认快捷键的配置 但默认快捷键不生效需要我手动开启

- (a) 诊断消失后延迟隐藏（`hide_delay_ms`，避免闪烁）
- (b) `:DiagFloat`（包装 Neovim 默认 `vim.diagnostic.open_float` 看详情）
- (c) `:DiagQflist` / `:DiagLoclist`（包装 `vim.diagnostic.setqflist` / `setloclist`）
- (d) 窗口内额外显示缓冲区名 / 当前行诊断条数
- (e) 鼠标点击窗口跳转（你的需求写"不需要鼠标操作"，默认不做）
- (f) `:DiagToggle` 手动开关窗口

```

## TODO

- tabline add extend callback statusline add
- hop
