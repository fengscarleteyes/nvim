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


# -t key ÀàÐÍ
# -C ×¢ÊÍ

ls ~/.ssh/

cat ~/.ssh/id_ed25519.pub

# ¸´ÖÆÉú³ÉºóµÄ ssh key£¬Í¨¹ý²Ö¿âÖ÷Ò³ ¡¸¹ÜÀí¡¹->¡¸²¿Êð¹«Ô¿¹ÜÀí¡¹->¡¸Ìí¼Ó²¿Êð¹«Ô¿¡¹ £¬½«Éú³ÉµÄ¹«Ô¿Ìí¼Óµ½²Ö¿âÖÐ¡£
```

- tabnine: 15916435511@163.com Redeyes@19881218

- TODO: add encoding utf8 gbk ...
- TODO: lspconfig usr ftplugin
- TODO: move line
