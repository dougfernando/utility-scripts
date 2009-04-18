$av_services = @("OracleMTSRecoveryService", "OracleServiceXE", "OracleXEClrAgent", "OracleXETNSListener")

foreach($service in $av_services) {
	Stop-Service $service -Force
} 

