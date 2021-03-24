# Input bindings are passed in via param block.
param($Timer)
function Start-WarrantySync {

  if ($ENV:DattoAPIURL) {
    update-warrantyinfo -dattormm -DattoAPIKey $ENV:DattoRMMKey -DattoAPISecret $ENV:DattoAPISecret -DattoAPIURL $ENV:DattoAPIURL -SyncWithSource -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
  
  if ($ENV:ItglueAPIURL) {
    update-warrantyinfo -ITGlue -ITGlueAPIURL $ENV:ITGlueAPIURL -ITGlueAPIKey $ENV:ITGlueAPIKey -SyncWithSource -ReturnWarrantyObject -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
  
  if ($ENV:NableHostname) {
    update-warrantyinfo -Nable -NableURL $ENV:NableHostname -NableJWT $ENV:JWTKey -SyncWithSource -ReturnWarrantyObject -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
    
  if ($ENV:HuduHostname) {
    update-warrantyinfo -Hudu -HuduBaseURL $ENV:HuduHostname -HuduAPIKey $ENV:huduKey -SyncWithSource -ReturnWarrantyObject -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
    
  if ($ENV:AutotaskHostName) {
    $ATCreds = New-Object System.Management.Automation.PSCredential ($ENV:AutotaskAPIUsername, ($ENV:AutotaskAPIpassword | ConvertTo-SecureString -Force -AsPlainText))

    update-warrantyinfo -Autotask -AutotaskAPIKey $ENV:AutotaskIntCode -AutotaskCredentials $ATCreds -SyncWithSource -ReturnWarrantyObject -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
    

  if ($ENV:CWMHostname) {
    update-warrantyinfo -CWManage -CWManagePublicKey $ENV:CWPubKey -CWManagePrivateKey $ENV:CWPrivKey -CWManageAPIURL $ENV:CWMHostname -CWManageCompanyID $ENV:CWMCompanyId -SyncWithSource -ReturnWarrantyObject -OverwriteWarranty
    Add-Content 'lastrun.txt' -Value "$(get-date)" -Force
  }
  
}

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()
Set-WarrantyAPIKeys -DellClientID $ENV:DellClientID -DellClientSecret $ENV:DellClientSecret
$ResumeLast = test-path 'Devices.json'
If ($ResumeLast) {
  Start-WarrantySync
}
else {
  $LastRunFile = test-path 'lastrun.txt'
  if ($LastRunFile) {
    Write-Host "No previous run detected, not resuming old session. Checking if it's time to run full sync"
    get-item 'Lastrun.txt' | ForEach-Object { if ($_.LastWriteTime -lt (get-date).AddDays(-7)) { Start-WarrantySync } }
  }
  else {
    write-host  "no lastrun.txt. Assuming first full sync"
    Start-WarrantySync
  }
}



# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
