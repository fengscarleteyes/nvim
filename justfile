set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set export

MyProxy := "http://192.168.43.1:7890"
# MyProxy := "http://192.168.10.118:7890"

export NO_PROXY := "localhost,127.0.0.1"
export HTTP_PROXY := MyProxy
export HTTPS_PROXY := MyProxy
export ALL_PROXY := MyProxy

# export SOCKET_PROXY=socket5://192.168.43.1:7890
# export SOCKET5_PROXY=socket5://192.168.43.1:7890

# default:
#     just --list

default:
    nvim
