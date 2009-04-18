$av_services = @("ccSetMgr", "ccSetMgr", "LiveUpdate", "SNAC", "ccEvtMgr", "Symantec AntiVirus")

foreach($service in $av_services) {
	Set-Service $service -StartupType "Automatic"
	Start-Service $service
} 

Set-Service "SmcService" -StartupType "Manual"
Start-Service "SmcService"