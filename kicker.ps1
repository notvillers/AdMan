If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "Ready to kick >:)"
$userName = Read-Host "Choose the victim's username"
$userQuery = (query user | findstr "$userName")
if (!($userQuery)) {
    Write-Host "'$userName' not found :("
} else {
    Write-Host "$userQuery"
    Write-Host "'$userName' found >:)"
    $hostName = (hostname)
    if (!($hostName)) {
        Write-Host "Can't get hostname :("
    } else {
        Write-Host "Hostname '$hostName' got >:)"
        $sessionId = ($userQuery -split '\s+')[2]
        Write-Host "KICKING >:)"
        logoff $sessionId /server:$hostName
    }
}
Write-Host "Bye!"
Read-Host "Press any key to exit"
