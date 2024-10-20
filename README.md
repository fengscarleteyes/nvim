# README

## install

- Windows

```shell
# windows
$env:HTTP_PROXY="http://192.168.10.118:7890"
$env:HTTPS_PROXY="http://192.168.10.118:7890"

winget install --id Microsoft.Powershell --source winget
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install --id=7zip.7zip -e
winget install zig.zig
npm install -g tree-sitter-cli
```
