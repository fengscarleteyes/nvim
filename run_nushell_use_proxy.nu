$env.https_proxy = "http://192.168.10.118:7890"
$env.http_proxy = "http://192.168.10.118:7890"
$env.no_proxy = "localhost,127.0.0.1"

let u = uname

if ($u.kernel-name == "Windows_NT") {
  cd ~\AppData\Local\nvim
  nvim
}

