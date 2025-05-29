<img src="./apps-neovim-icon-1024x1024.png" data-canonical-src="https://camo.githubusercontent.com/..." width="100" height="100" />

---

# README

<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="25" />

- Install

```shell
cd ~/.config/nvim # Linux
git clone https://github.com/fengscarleteyes/nvim.git
```

```powershell
cd ~\AppData\Local\nvim # Windows
git clone https://github.com/fengscarleteyes/nvim.git
```

## TODO:

## version manager

> https://github.com/y3owk1n/nvs

```bash
# Linux

# install
curl -fsSL https://raw.githubusercontent.com/y3owk1n/nvs/main/install.sh | bash

# uninstall
curl -fsSL https://raw.githubusercontent.com/y3owk1n/nvs/main/uninstall.sh | bash
```

### Using a released binary

> https://github.com/y3owk1n/nvs/releases

```bash
$ nvs use stable
✓ Switched to Neovim stable

$ nvim -v
NVIM v0.10.4
Build type: Release
LuaJIT 2.1.1713484068
Run "nvim -V1 -v" for more info

$ nvs use nightly
✓ Switched to Neovim nightly

$ nvim -v
NVIM v0.11.0-dev-1961+g7e2b75760f
Build type: RelWithDebInfo
LuaJIT 2.1.1741571767
Run "nvim -V1 -v" for more info

$ nvs install 0.10.0
ℹ Resolving version v0.10.0...
ℹ Installing Neovim v0.10.0...
✓ Installation successful!

$ nvs use 0.10.0
✓ Switched to Neovim v0.10.0

$ nvim -v
NVIM v0.10.0
Build type: Release
LuaJIT 2.1.1713484068
Run "nvim -V1 -v" for more info
```

## Python

### VENV

```bash
uv venv .venv --python 3.13
source .venv/bin/activate

# nushell
# overlay use .venv/Scripts/activate.nu
```

## Other

- tabnine: 163.com R@

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

string/table	模式，如 "n"（普通模式）、"i"（插入模式）、"v"（可视模式），或组合 {"n", "v"}
lhs	string	左边按键（触发映射的按键组合），如 "<leader>ff"
rhs	string/function	右边内容，可以是字符串（如 ":echo 'Hello'<CR>"）或 Lua 函数
opts	table	可选参数（见下方）

opts 可选参数：
选项	类型	默认值	作用
noremap	boolean	true	是否禁用递归映射（推荐设为 true，避免无限循环）
silent	boolean	false	是否静默执行（不显示命令）
nowait	boolean	false	是否立即应用映射，不等待可能的更长匹配
expr	boolean	false	是否将 rhs 视为表达式（VimScript）
desc	string	nil	映射的描述（显示在 :which-key 等插件中）
)
```
