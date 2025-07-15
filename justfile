set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

alias pp := powershell_porxy
alias ppp := powershell_phone_proxy

[windows]
powershell_porxy:
    $MyProxy = "http://192.168.10.118:7890"
    $env:HTTP_PROXY = $MyProxy
    $env:HTTPS_PROXY = $MyProxy
    $env:NO_PROXY = "localhost,127.0.0.1"
    Set-Location ~\AppData\Local\nvim
    nvim

[windows]
powershell_phone_proxy:
    $MyProxy = "http://192.168.43.1:7890"
    $env:HTTP_PROXY = $MyProxy
    $env:HTTPS_PROXY = $MyProxy
    $env:NO_PROXY="localhost,127.0.0.1"
    Set-Location ~\AppData\Local\nvim
    nvim
