# ���ô����ַ�Ͷ˿�
$env:HTTP_PROXY = "http://192.168.10.118:7890"
$env:HTTPS_PROXY = "http://192.168.10.118:7890"
$env:NO_PROXY="localhost,127.0.0.1"

# ��ʾ���õĻ�������
Write-Host "HTTP_PROXY ����Ϊ: $($env:HTTP_PROXY)"
Write-Host "HTTPS_PROXY ����Ϊ: $($env:HTTPS_PROXY)"
Write-Host "NO_PROXY ����Ϊ: $($env:NO_PROXY)"

cd ~\AppData\Local\nvim
nvim
