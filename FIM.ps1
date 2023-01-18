
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Write-Host ""
Write-Host "What would you like to do?" 
write-Host "A) Collect new Baseline?"
write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists {
    $baselineExists = Test-Path -Path .\addyourbaseline.txt
    
    if ($baselineExists) {
    #Delete it
    Remove-Item -Path .\addyourbaseline.txt
}
}
if ($response -eq "A".ToUpper()) {
    # Delete baseline.txt if it already exits
    Erase-Baseline-If-Already-Exists
    # Calculate Hash from the target files and store in baseline.txt
    
    # Collect all files in the file folder 
    $Files = Get-ChildItem -Path .\addyourTestFile
    
    # For each calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\addyourbaseline.txt -Append
    }
}
elseif ($response -eq "B".ToUpper()) {
    
    $fileHashDictionary = @{}
    
    # Load file|hash from baseline.txt and store in a dictionary
    $filePathsandHashes = Get-Content -Path .\addyourbaseline.txt
    
    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        
    }
   
    # Begin monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 1
      
        $Files = Get-ChildItem -Path .\addyourTestFile

    # For each calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName

       # Notify if a new file has been created
       if ($fileHashDictionary[$hash.Path] -eq $null) {
            # A new file has ben created!
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
       }
       else {
       #Notify if a new file has been changed 
       if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
            # The file has not changed
        }
        else {
            # File has been Compromised!
            Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
        }
    }     
   
  }  
  foreach ($key in $fileHashDictionary.Keys) {
      $baselineFileStillExists = Test-Path -Path $key
      if (-Not $baselineFileStillExists) {
         #file deleted
         Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed
       }
    
}
}
}

