$av_services = @("OracleMTSRecoveryService", "OracleServiceXE", "OracleXEClrAgent", "OracleXETNSListener")

foreach($service in $av_services) {
	Start-Service $service
} 

