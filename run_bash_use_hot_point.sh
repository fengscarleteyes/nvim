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
