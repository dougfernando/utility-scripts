echo "CONNECTING TO CHEMTECH VPN..."
echo "---------------------------------------------"
echo ""
echo "Going to command line mode..."
& "C:\Program Files\CheckPoint\SecuRemote\bin\scc.exe" setmode cli
echo ""

$attempt = 0
$maxNumberOfAttempts = 5

$success = $false
do {
  echo "Connecting to server: 200.173.214.10..."
  $outp = & "C:\Applications\CheckPoint\SecuRemote\bin\scc.exe" connect -p "200.173.214.10";
  echo $outp
  foreach ($item in $outp) { 
    if ($item.ToString().ToUpper().IndexOf("SUCCEEDED") -ne -1) {
      $success = $true;
      break
    }
  }
  if ($success) {
    echo "Connection was OK!";
    echo "Changing the host file to chemtech mode...";
    & "C:\users\douglas\scripts\use_hosts_chemtech.ps1"
  } else {
    echo "Connection was NOK, trying again.";
    $attempt = $attempt + 1
  }
} while(-not $success -and $attempt -le $maxNumberOfAttempts);

