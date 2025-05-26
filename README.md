<img src="./apps-neovim-icon-1024x1024.png" data-canonical-src="https://camo.githubusercontent.com/..." width="100" height="100" />

---

# README

## TODO:

## DS

- `c2stOWE3YWExZTdhZGUxNGViNTgwNmY1NjA0YzVhN2ZmYWM=`

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
