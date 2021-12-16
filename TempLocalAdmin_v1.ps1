# Parameter for user
Param(
[Parameter(Mandatory=$True)]
[int]$Minutes,
[Parameter(Mandatory=$True)]
[string]$Domain,
[Parameter(Mandatory=$True)]
[string]$User
)

# Some variables for later
$DomainAndUser = $Domain+'\'+$User
[int]$MinutesPlusOne = $Minutes + 1

# Write output for who is being promoted to temp admin
$WasHere = ' was promoted as temporary local administrator'
Write-Host $DomainAndUser$WasHere

# Adds user to 'Administrators' group
Add-LocalGroupMember -Group "Administrators" -Member $DomainAndUser

# Creates variable to remove user from 'Administrators' group
$RemoveGroupMember = 'Remove-LocalGroupMember -Group "Administrators" -Member '

# Create variable for scheduled task name
$N1 = 'Remove '
$N2 = ' as temp local admin'
$N = $N1+$Domain+' '+$User+$N2

# Create a scheduled task to remove the local admin and self destruct
$A = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $RemoveGroupMember$DomainAndUser
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddMinutes($Minutes); $t.EndBoundary = (get-date).AddMinutes($MinutesPlusOne).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:00:10
Register-ScheduledTask -Force -user SYSTEM -TaskName $N -Action $A -Trigger $T -Settings $S

# Create Teams webhook message
# EDIT ME!!! Be sure to place your unique Teams webhook URI below on the line "URI" = 'https://YOUR.URI.HERE'
[String]$Expires = (get-date).AddMinutes($Minutes)
[String]$IP = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress[0]
$JSONBody = [PSCustomObject][Ordered]@{
"@type" = "MessageCard"
"@context" = "<http://schema.org/extensions>"
"themeColor" = '0078D7'
"text" = "`n
Temporary local administrator rights have been granted on a computer using MECM scripts. An Event Viewer entry has been created on the local PC under the Application log source name Temp Local Admin and Event ID 42. Additional logging can be found in the MECM console under Monitoring\Overview\Script Status or Monitoring\Overview\System Status\Status Message Queries filtering by message ID 40806 and/or 40807. <br /> <br />
<b>Computer:</b> $env:computername <br />
<b>IP Address:</b> $IP <br />
<b>User:</b> $DomainAndUser <br />
<b>Expires:</b> $Expires"
}
$TeamMessageBody = ConvertTo-Json $JSONBody
$parameters = @{
"URI" = 'https://YOUR.URI.HERE'
"Method" = 'POST'
"Body" = $TeamMessageBody
"ContentType" = 'application/json'
}
Invoke-RestMethod @parameters

# Create Event Log Entry
$Message = $DomainAndUser+' was promoted as temporary local administrator expiring '+$Expires+'. This action was performed using the Scripts feature in MECM. Additional logging can be found in the MECM console under Monitoring\Overview\Script Status or Monitoring\Overview\System Status\Status Message Queries filtering by message ID 40806 and/or 40807.'
New-EventLog -LogName Application -Source "Temp Local Admin"
Write-EventLog -LogName Application -Source "Temp Local Admin" -EntryType Information -EventId 42 -Message $Message

# Brought to you by Carls Jr