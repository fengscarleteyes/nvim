# TODO: windows install script
# https://dev.to/kaiwalter/get-neovim-plugins-with-build-processes-working-on-windows-i39

# # 设置代理地址和端口
$env:MyProxy = "http://192.168.10.118:7890"
$env:HTTP_PROXY = $env:MyProxy
$env:HTTPS_PROXY = $env:MyProxy
$env:NO_PROXY="localhost,127.0.0.1"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

winget install --id Microsoft.Powershell --source winget --proxy $env:MyProxy

# install curl
winget install cURL.cURL --proxy $env:MyProxy

# install NeoVim with WinGet, if not already present on system
if (!$(Get-Command nvim -ErrorAction SilentlyContinue)) {
    # winget install Neovim.Neovim --proxy $env:MyProxy
    winget install Neovim.Neovim.Nightly --proxy $env:MyProxy
}

# install ripgrep
if (!$(Get-Command rg -ErrorAction SilentlyContinue)) {
  winget install BurntSushi.ripgrep.MSVC --proxy $env:MyProxy
}

# install fd
if (!$(Get-Command fd -ErrorAction SilentlyContinue)) {
  winget install sharkdp.fd --proxy $env:MyProxy
}

# install lazygit
if (!$(Get-Command lazygit -ErrorAction SilentlyContinue)) {
  winget install JesseDuffield.lazygit --proxy $env:MyProxy
}

# install zig
if (!$(Get-Command zig -ErrorAction SilentlyContinue)) {
  winget install zig.zig --proxy $env:MyProxy
}

# $7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
# install 7z
if (!$(Get-Command 7z -ErrorAction SilentlyContinue)) {
  winget install --id=7zip.7zip -e --proxy $env:MyProxy
}
# Write-Output $7zipPath

# install npm
if (!$(Get-Command npm -ErrorAction SilentlyContinue)) {
  winget install -e --id OpenJS.NodeJS --proxy $env:MyProxy
}

npm install -g tree-sitter-cli

# install yazi
if (!$(Get-Command npm -ErrorAction SilentlyContinue)) {
  winget install -e --id sxyazi.yazi --proxy $env:MyProxy
  winget install Gyan.FFmpeg 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick --proxy $env:MyProxy
}

