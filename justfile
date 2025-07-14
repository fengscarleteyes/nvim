# 使用 PowerShell 替代 sh:
# set shell := ["powershell.exe", "-c"]
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

alias pp := powershell_porxy

powershell_porxy:
    $MyProxy = "http://192.168.10.118:7890"
    $env:HTTP_PROXY = $MyProxy
    $env:HTTPS_PROXY = $MyProxy
    $env:NO_PROXY = "localhost,127.0.0.1"
