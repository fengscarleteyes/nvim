export MyProxy="http://192.168.43.1:7890"
export NO_PROXY="localhost,127.0.0.1"
export HTTPS_PROXY=$MyProxy
export HTTP_PROXY=$MyProxy

cd ~/.config/nvim
nvim
