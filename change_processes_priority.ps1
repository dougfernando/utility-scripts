$processes = @('launchy')

foreach($process in $processes) {
  ps -processname $process | %{ $_.PriorityClass = 'AboveNormal' }
}


