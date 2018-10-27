#creates mail flow rule to redirect all messages from a known compromised email address to a moderator mailbox for approval before delivery

#import required modules and connect to Office 365 if not already loaded
if (!(Get-Module msonline))
    {
    Import-Module msonline
    $cred = Get-Credential
    Connect-MsolService -Credential $cred
    $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $s
    }

$rulename = "BEC Redirect"
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
$BECaddress = Read-Host "Enter the compromised email address"
$ApprovalAddress = Read-Host "Enter the email address to send all potentially compromised email to for approval"

if (!$rule) 
{
    New-TransportRule -Name $ruleName -From $BECadddress -ModerateMessagebyUser $ApprovalAddress
}

else 
{
    Set-TransportRule -Identity $ruleName -From $BECadddress -ModerateMessagebyUser $ApprovalAddress
}