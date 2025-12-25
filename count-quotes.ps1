$s = Get-Content -Raw .\install-paczki.ps1
$dq = ($s.ToCharArray() | Where-Object { $_ -eq '"' }).Count
$sq = ($s.ToCharArray() | Where-Object { $_ -eq "'" }).Count
Write-Output "DoubleQuotes=$dq SingleQuotes=$sq"
