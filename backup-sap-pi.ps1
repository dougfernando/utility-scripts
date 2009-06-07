param (
    [string]$source = $(Throw "You have to specify a source directory."),
    [string]$destiny = $(Throw "You have to specify a destiny directory."))

function has-space-in-disk-directory([int] $size,  [string] $destiny) {

  $drive = $destiny.Substring(0, 2)
  $drive_free_space = (Get-WmiObject Win32_LogicalDisk -filter ("DeviceID = '" + $drive + "'")).FreeSpace

  $result = $drive_free_space -ge $size

  $result
}


function backup-sap-pi([string] $source, [string] $destiny) {

  $backup_date = (Get-Date –f "yyyy-MM-dd-mm")

  $source_dir_size =  (ls $source -recurse | measure-object Length -sum).Sum
  echo "Source directory ($source) size: $source_dir_size"

  $has_destiny_space = has-space-in-disk-directory $source_dir_size $destiny -eq True
  echo "Does it have enough space in $destiny ? $has_destiny_space"

  $destiny_dir = "$destiny\$backup_date" + "_" + (get-item $source).Name
  echo "Destiny directory: $destiny_dir"
  
  if ($has_destiny_space) {
    echo "Copying: $source to: $destiny_dir ..."
    Copy-Item -Path $source -Destination $destiny_dir -Recurse
  } else {
    do {
      echo "No space, it will have to remove the oldest directory"
      $dir_to_delete = @(ls -path "$destiny\2009*" | sort Name)[0]
      echo "Removing: $dir_to_delete ..."
      Remove-Item $dir_to_delete -Recurse

      $has_destiny_space = has-space-in-disk-directory $source_dir_size $destiny -eq True
    } while($has_destiny_space -ne $true)
    
    echo "Copying: $source to: $destiny_dir ..."
    Copy-Item -Path $source -Destination $destiny_dir -Recurse
  }
}

backup-sap-pi $source $destiny

