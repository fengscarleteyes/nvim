# README

## install

- Windows

```shell
# set proxy

# linux
export NO_PROXY="localhost,127.0.0.1"
export HTTPS_PROXY="http://192.168.43.1:7890"
export HTTP_PROXY="http://192.168.43.1:7890"
 
```

```shell
# windows
$env:HTTP_PROXY="http://192.168.10.195:7890"
$env:HTTPS_PROXY="http://192.168.10.195:7890"
$env:NO_PROXY="localhost,127.0.0.1"

$env:HTTPS_PROXY="http://192.168.10.118:7890"
$env:HTTP_PROXY="http://192.168.10.118:7890"
$env:NO_PROXY="localhost,127.0.0.1"

winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install --id=7zip.7zip -e
winget install zig.zig
winget install --id=JesseDuffield.lazygit -e 

sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit

winget install --id Microsoft.Powershell --source winget
winget install -e --id OpenJS.NodeJS
npm install -g tree-sitter-cli

npm config set proxy http://192.168.10.195:7890
npm config set https-proxy https://192.168.10.195:7890
npm config set registry https://registry.npm.taobao.org
npm config set registry=https://registry.npmjs.org

npm config delete proxy
npm config delete https-proxy

```

- linux

```shell
# Fedora

# install neovim nightly
sudo dnf copr enable agriffis/neovim-nightly
sudo dnf upgrade neovim python{2,3}-neovim

sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

## TODO

## SSH

```shell
Gitee SSH:

ssh-keygen -t ed25519 -C "Gitee SSH Key"


# -t key 类型
# -C 注释

ls ~/.ssh/

cat ~/.ssh/id_ed25519.pub

# 复制生成后的 ssh key，通过仓库主页 「管理」->「部署公钥管理」->「添加部署公钥」 ，将生成的公钥添加到仓库中。
```

- tabnine: 15916435511@163.com Redeyes@19881218


