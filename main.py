import os
import subprocess

# "http://192.168.10.118:7890"
# "http://192.168.43.1:7890"


def main() -> None:
    """
    Set proxy for neovim
    """
    proxy_text: str = "192.168.43.1:7890"
    http_proxy_text: str = f"http://{proxy_text}"
    socket_proxy_text: str = f"socket5://{proxy_text}"
    local_text: str = "localhost,127.0.0.1"

    os.environ["NO_PROXY"] = local_text
    os.environ["HTTP_PROXY"] = http_proxy_text
    os.environ["HTTPS_PROXY"] = http_proxy_text
    os.environ["ALL_PROXY"] = http_proxy_text
    os.environ["SOCKET_PROXY"] = socket_proxy_text
    os.environ["SOCKET5_PROXY"] = socket_proxy_text
    result = subprocess.run("nvim", text=True, check=True)
    print(result)


if __name__ == "__main__":
    main()


# export MyProxy="http://192.168.43.1:7890"
# export NO_PROXY="localhost,127.0.0.1"
# export HTTP_PROXY=$MyProxy
# export HTTPS_PROXY=$MyProxy
# export ALL_PROXY=$MyProxy
# export http_proxy=$MyProxy
# export https_proxy=$MyProxy
# export all_proxy=$MyProxy
# export SOCKET_PROXY=socket5://192.168.43.1:7890
# export SOCKET5_PROXY=socket5://192.168.43.1:7890
# export socket_proxy=socket5://192.168.43.1:7890
# export socket5_proxy=socket5://192.168.43.1:7890
# cd ~/.config/nvim
# nvim
#
# $MyProxy = "http://192.168.43.1:7890"
# $env:HTTP_PROXY = $MyProxy
# $env:HTTPS_PROXY = $MyProxy
# $env:NO_PROXY="localhost,127.0.0.1"
# # 显示设置的环境变量
# Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
# Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
# Write-Host "NO_PROXY: $($env:NO_PROXY)"
# Set-Location ~\AppData\Local\nvim
# nvim
#
# # 设置代理地址和端口
# $MyProxy = "http://192.168.10.118:7890"
# $env:HTTP_PROXY = $MyProxy
# $env:HTTPS_PROXY = $MyProxy
# $env:NO_PROXY = "localhost,127.0.0.1"
# # 显示设置的环境变量
# Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
# Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
# Write-Host "NO_PROXY: $($env:NO_PROXY)"
# Set-Location ~\AppData\Local\nvim
# nvim
#
# # nushell
# # let proxy_str = "http://192.168.43.1:7890"
# let proxy_str = "http://192.168.10.118:7890"
# $env.https_proxy = $proxy_str
# $env.http_proxy  = $proxy_str
# $env.no_proxy    = "localhost,127.0.0.1"
#
# let u = uname
# if ($u.kernel-name == "Windows_NT") {
#   cd ~\AppData\Local\nvim
#   nvim
# } else {
#   cd ~/.config/nvim
#   nvim
# }
