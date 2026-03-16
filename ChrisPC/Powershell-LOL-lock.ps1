# Reguła: "Chat Leage of legends" (blokada wychodząca) dla TCP i UDP na wszystkich portach
$displayName      = "Chat Leage of legends"
$ruleBaseName     = "ChatLeagueOfLegends"
$remoteAddresses  = @("172.65.192.156", "172.65.223.136")
$remotePortRange  = "1-65535"
$direction        = "Outbound"
$action           = "Block"
$localAddress     = "Any"

$remoteAddressCsv = ($remoteAddresses -join ",")

foreach ($proto in @("TCP","UDP")) {
    $name = "$ruleBaseName-$proto"

    $rule = Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue

    if ($rule) {
        Set-NetFirewallRule -Name $name -DisplayName $displayName -Direction $direction -Action $action -Enabled True | Out-Null
        Get-NetFirewallRule -Name $name | Set-NetFirewallAddressFilter -LocalAddress $localAddress -RemoteAddress $remoteAddressCsv | Out-Null
        Get-NetFirewallRule -Name $name | Set-NetFirewallPortFilter    -Protocol $proto -RemotePort $remotePortRange | Out-Null
        Write-Host "Zaktualizowano: $displayName ($proto)"
    } else {
        New-NetFirewallRule -Name $name -DisplayName $displayName `
            -Direction $direction -Action $action -Enabled True `
            -Protocol $proto -LocalAddress $localAddress -RemoteAddress $remoteAddressCsv `
            -RemotePort $remotePortRange | Out-Null
        Write-Host "Dodano: $displayName ($proto)"
    }
}

# Podgląd
Get-NetFirewallRule -Name "$ruleBaseName-*" |  Select-Object Name, DisplayName, Direction, Action, Enabled