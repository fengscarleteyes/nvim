# 设置代理地址和端口
$MyProxy = "http://192.168.10.118:7890"
$env:HTTP_PROXY = $MyProxy
$env:HTTPS_PROXY = $MyProxy
$env:NO_PROXY="localhost,127.0.0.1"

# 显示设置的环境变量
Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
Write-Host "NO_PROXY: $($env:NO_PROXY)"

cd ~\AppData\Local\nvim
nvim
