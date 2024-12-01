# README

## install

- Windows

```shell
# windows
$env:HTTP_PROXY="http://192.168.10.195:7890"
$env:HTTPS_PROXY="http://192.168.10.195:7890"

winget install --id Microsoft.Powershell --source winget
winget install -e --id OpenJS.NodeJS
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install --id=7zip.7zip -e
winget install zig.zig
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
```

## TODO

- https://github.com/mfussenegger/nvim-dap
- https://github.com/rcarriga/nvim-dap-ui
- https://github.com/theHamsta/nvim-dap-virtual-text

