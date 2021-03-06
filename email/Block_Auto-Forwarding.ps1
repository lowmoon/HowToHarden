$MSOnline = Get-Module -ListAvailable -Name MSOnline
if (!$MSOnline)
{
    Install-Module MSOnline
}   

#Connect using MFA
    $CreateEXOPSSession = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -ErrorAction SilentlyContinue -Force | Select -Last 1).DirectoryName
    . "$CreateEXOPSSession\CreateExoPSSession.ps1"
    Connect-EXOPSSession
    Connect-MsolService

#import required modules and connect to Office 365 if not already loaded
if (!(Get-Module msonline))
    {
    Import-Module msonline
    $cred = Get-Credential
    Connect-MsolService -Credential $cred
    $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $s
    }

#Create a new transport rule that blocks auto-forwarding of emails to an external domain
New-TransportRule -Name "Block Auto-Forwarding" -FromScope InOrganization -SentToScope NotInOrganization -MessageTypeMatches AutoForward -NotifySender RejectMessage -SenderAddressLocation Header -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Client Forwarding Rules To External Domains Are Not Allowed. Contact IT Support For Assistance"