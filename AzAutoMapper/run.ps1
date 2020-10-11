using namespace System.Net
param($Request, $TriggerMetadata)
#
#
$TenantID = $Request.Query.TenantID
$user = $Request.Query.Username
 
$body = @{
    'resource'      = 'https://graph.microsoft.com'
    'client_id'     = $ENV:ApplicationId
    'client_secret' = $ENV:ApplicationSecret
    'grant_type'    = "client_credentials"
    'scope'         = "openid"
}
$ClientToken = Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/token" -Body $body -ErrorAction Stop
$headers = @{ "Authorization" = "Bearer $($ClientToken.access_token)" }
$UserID = (Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/users/$($user)" -Headers $Headers -Method Get -ContentType "application/json").id
 
$AllTeamsURI = "https://graph.microsoft.com/beta/users/$($UserID)/JoinedTeams"
$Teams = (Invoke-RestMethod -Uri $AllTeamsURI -Headers $Headers -Method Get -ContentType "application/json").value
$MemberOf = foreach ($Team in $Teams) {
    $SiteRootUri = "https://graph.microsoft.com/beta/groups/$($Team.id)/sites/root"
    $SiteRootReq = Invoke-RestMethod -Uri $SiteRootUri  -Headers $Headers -Method Get -ContentType "application/json"
    $SiteDrivesUri = "https://graph.microsoft.com/beta/groups/$($Team.id)/sites/root/Lists"
    $SitesDrivesReq = (Invoke-RestMethod -Uri $SiteDrivesUri -Headers $Headers -Method Get -ContentType "application/json").value | where-object { $_.Name -eq "Shared Documents" }
    $DriveInfo = $SitesDrivesReq.ParentReference.siteid -split ','
    if ($SiteRootReq.description -like "*no-auto-map*") { continue }
    if ($null -eq [System.Web.HttpUtility]::UrlEncode($SitesDrivesReq.id)) { continue }
    [pscustomobject] @{
        SiteID    = [System.Web.HttpUtility]::UrlEncode("{$($DriveInfo[1])}")
        WebID     = [System.Web.HttpUtility]::UrlEncode("{$($DriveInfo[2])}")
        ListID    = [System.Web.HttpUtility]::UrlEncode("{$($SitesDrivesReq.id)}")
        WebURL    = [System.Web.HttpUtility]::UrlEncode($SiteRootReq.webUrl)
        Webtitle  = [System.Web.HttpUtility]::UrlEncode($($Team.displayName)).Replace("+", "%20")
        listtitle = [System.Web.HttpUtility]::UrlEncode($SitesDrivesReq.name)
    }
 
}
 
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $MemberOf
    })