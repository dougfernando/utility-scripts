$av_services = @("ufad-ws60", "vmauthdservice", "vmnetdhcp", "vmware nat service")

foreach($service in $av_services) {
	Stop-Service $service -Force
} 

