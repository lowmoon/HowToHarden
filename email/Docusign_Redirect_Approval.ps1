#creates mail flow rule to redirect all messages containing "docusign" keyword to a moderator mailbox for approval before delivery

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

#set approval address
$ApprovalAddress = Read-Host "Enter the email address to send all Docusign emails to for approval"

#create rule
New-TransportRule -Name "Redirect Docusign for Approval" -SubjectOrBodyContainsWords "docu sign",docusign,docu-sign -ModerateMessagebyUser $ApprovalAddress