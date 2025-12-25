param(
    [string]$ListFile = "paczki.txt",
    [switch]$ForceChocoInstall,
    [switch]$FullUpgrade
)

# Restart as admin if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Uruchamiam ponownie jako administrator..."
    Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File \"$($MyInvocation.MyCommand.Path)\"" -Verb RunAs
    exit
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$listPath = Join-Path $scriptDir $ListFile

if (-not (Test-Path $listPath)) {
    Write-Error "Plik z lista pakietow nie znaleziony: $listPath"
    exit 1
}

function Ensure-Choco {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey nie jest zainstalowany. Instalowanie..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Error "Instalacja Chocolatey nie powiodla sie."
            exit 1
        }
    }
}

$Ensure = Ensure-Choco
Ensure-Choco

# Kolekcja nieudanych elementow (uzywana zarowno dla "choco upgrade all" jak i pojedynczych pakietow)
$failed = @()

if ($FullUpgrade) {
    Write-Host "Wykonuje 'choco upgrade all' (pelna aktualizacja)..."
    try {
        choco upgrade all -y --no-progress
        if ($LASTEXITCODE -ne 0) {
            $failed += 'choco-upgrade-all'
            Write-Warning "Polecenie 'choco upgrade all' zakoczyo si kodem $LASTEXITCODE"
        }
    } catch {
        $failed += 'choco-upgrade-all'
        Write-Warning "Blad podczas 'choco upgrade all': $_"
    }
}

$packages = Get-Content $listPath | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
if (-not $packages) {
    Write-Host "Brak pakietow do zainstalowania."
    exit 0
}

# Wyświetl listę pakietów jako pełne komendy instalacyjne
Write-Host "Lista pakietow (komendy do uruchomienia):"
$packages | ForEach-Object { Write-Host "choco install $_ -y --no-progress" }
Write-Host "---"

$failed = @()
foreach ($pkg in $packages) {
    Write-Host "Instaluje: $pkg"
    try {
        choco install $pkg -y --no-progress
        if ($LASTEXITCODE -ne 0) {
            $failed += $pkg
                                Write-Warning "Instalacja $pkg zwrocila kod $LASTEXITCODE"
        }
    } catch {
        $failed += $pkg
        Write-Warning ("Bd instalacji {0}: {1}" -f $pkg, $_)
    }
}

if ($failed.Count -eq 0) {
    Write-Host "Wszystkie pakiety zainstalowane pomyslnie."
    exit 0
    } else {
    Write-Warning "Nie udalo sie zainstalowac nastepujacych pakietow:"
    $failed | ForEach-Object { Write-Warning (" - {0}" -f $_) }
    exit 2
}
