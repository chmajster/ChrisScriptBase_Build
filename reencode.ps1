$t = Get-Content -Raw .\install-paczki.ps1
[System.IO.File]::WriteAllText((Resolve-Path .\install-paczki.ps1).Path, $t, [System.Text.Encoding]::UTF8)
Write-Output 'Wrote with .NET UTF8 (BOM)'
