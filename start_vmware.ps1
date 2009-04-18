$av_services = @("ufad-ws60", "vmauthdservice", "vmnetdhcp", "vmware nat service")

foreach($service in $av_services) {
	Start-Service $service
} 

