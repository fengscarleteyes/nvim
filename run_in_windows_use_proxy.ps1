# ���ô����ַ�Ͷ˿�
$MyProxy = "http://192.168.10.118:7890"
$env:HTTP_PROXY = $MyProxy
$env:HTTPS_PROXY = $MyProxy
$env:NO_PROXY="localhost,127.0.0.1"

# ��ʾ���õĻ�������
Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
Write-Host "HTTPS_PROXY: $($env:HTTPS_PROXY)"
Write-Host "NO_PROXY: $($env:NO_PROXY)"

cd ~\AppData\Local\nvim
nvim
