$path = (Resolve-Path .\install-paczki.ps1).Path
$s = Get-Content -Raw $path
$out = -join ($s.ToCharArray() | ForEach-Object { if ([int][char]$_ -le 127) { $_ } else { '' } })
[System.IO.File]::WriteAllText($path, $out, [System.Text.Encoding]::UTF8)
Write-Output "Sanitized file (non-ASCII removed)"
