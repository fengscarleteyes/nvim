let proxy_str = "http://192.168.10.118:7890"

$env.https_proxy = $proxy_str
$env.http_proxy  = $proxy_str
$env.no_proxy    = "localhost,127.0.0.1"

$env.OPENAI_API_KEY = "sk-9a7aa1e7ade14eb5806f5604c5a7ffac",

let u = uname

if ($u.kernel-name == "Windows_NT") {
  cd ~\AppData\Local\nvim
  nvim
} else {
  cd ~/.config/nvim
  nvim
}
