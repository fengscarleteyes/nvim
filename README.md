<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="100" />

---

# README

- Install

```shell
sudo pacman -S fzf
sudo pacman -S fd
sudo pacman -S ripgrep
sudo pacman -S bat
sudo pacman -S git-delta
sudo pacman -S chafa viu ueberzugpp

git clone git@github.com:fengscarleteyes/nvim.git
```

## version manager

> https://github.com/y3owk1n/nvs

## Python

### VENV

```bash
uv venv .venv --python 3.13
source .venv/bin/activate

# nushell
# overlay use .venv/Scripts/activate.nu
```

## Other

- tabnine: 163R@
- fittencode: fenR@

## Shell

```bash
export MyProxy="http://192.168.43.1:7890"

export NO_PROXY="localhost,127.0.0.1"

export HTTP_PROXY=$MyProxy
export HTTPS_PROXY=$MyProxy
export ALL_PROXY=$MyProxy

export http_proxy=$MyProxy
export https_proxy=$MyProxy
export all_proxy=$MyProxy

export SOCKET_PROXY=socket5://192.168.43.1:7890
export SOCKET5_PROXY=socket5://192.168.43.1:7890
export socket_proxy=socket5://192.168.43.1:7890
export socket5_proxy=socket5://192.168.43.1:7890

cd ~/.config/nvim
nvim
```

```powershell
$MyProxy = "http://192.168.43.1:7890"
$env:HTTP_PROXY = $MyProxy
$env:HTTPS_PROXY = $MyProxy
$env:NO_PROXY="localhost,127.0.0.1"

# 显示设置的环境变量
Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
Write-Host "NO_PROXY: $($env:NO_PROXY)"

Set-Location ~\AppData\Local\nvim
nvim
```

```powershell
# 设置代理地址和端口
$MyProxy = "http://192.168.10.118:7890"
$env:HTTP_PROXY = $MyProxy
$env:HTTPS_PROXY = $MyProxy
$env:NO_PROXY = "localhost,127.0.0.1"

# 显示设置的环境变量
Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
Write-Host "NO_PROXY: $($env:NO_PROXY)"

Set-Location ~\AppData\Local\nvim
nvim
```

```nushell
# nushell
# let proxy_str = "http://192.168.43.1:7890"
let proxy_str = "http://192.168.10.118:7890"

$env.https_proxy = $proxy_str
$env.http_proxy  = $proxy_str
$env.no_proxy    = "localhost,127.0.0.1"

let u = uname

if ($u.kernel-name == "Windows_NT") {
  cd ~\AppData\Local\nvim
  nvim
} else {
  cd ~/.config/nvim
  nvim
}
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
