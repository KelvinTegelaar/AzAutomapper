
Add-Type -AssemblyName System.Web
#########################
$AutoMapURL = "YourAzMapURL"
$AutomapAPIKey = "YourAzMapKey"
#########################
write-host "Grabbing OneDrive info from registry" -ForegroundColor Green
$TenantID = (get-itemproperty "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\").ConfiguredTenantId
$TenantDisplayName = (get-itemproperty "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\").Displayname
$username = (get-itemproperty "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\").userEmail
$CurrentlySynced = (get-itemproperty "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\$($tenantdisplayname)" -ErrorAction SilentlyContinue)
Write-Host "Retrieving all possible teams."  -ForegroundColor Green
$ListOfTeams = Invoke-RestMethod -Method get -uri "$($AutoMapURL)?Tenantid=$($TenantID)&Username=$($Username)&code=$($AutomapAPIKey)" -UseBasicParsing
$Upn = [System.Web.HttpUtility]::Urldecode($username)
foreach ($Team in $ListOfTeams) {
    write-host "Checking if site is not already synced" -ForegroundColor Green
    $sitename = [System.Web.HttpUtility]::Urldecode($Team.Webtitle)
    if ($CurrentlySynced.psobject.Properties.name -like "*$($sitename) -*") {
        write-host "Site $Sitename is already being synced. Skipping." -ForegroundColor Green 
        continue
    }
    else {
        write-host "Mapping Team: $Sitename" -ForegroundColor Green
        Start-Process "odopen://sync/?siteId=$($team.SiteID)&webId=$($team.webid)&listId=$($team.ListID)&userEmail=$upn&webUrl=$($team.Weburl)&webtitle=$($team.Webtitle)"
        start-sleep 5
    }
}