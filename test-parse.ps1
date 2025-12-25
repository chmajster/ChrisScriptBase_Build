$scriptPath = 'c:\Users\Chris\Documents\GitHub\ChrisScriptBase_Build\install-paczki.ps1'
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($scriptPath,[ref]$null,[ref]$errors)
if ($errors) {
    $errors | Format-List
    exit 1
} else {
    Write-Output 'Syntax OK'
    exit 0
}