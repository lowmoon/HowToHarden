#creates mail flow rule to redirect all messages containing attachments with certain extensions to a moderator mailbox for approval before delivery

#import required modules and connect to Office 365 if not already loaded
if (!(Get-Module msonline))
    {
    Import-Module msonline
    $cred = Get-Credential
    Connect-MsolService -Credential $cred
    $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $s
    }

$rulename = "Suspicious Attachment Redirect"
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
$ExtensionList =  'ADE','ADP','APP','ASA','ASP','BAS','BAT','CER','CHM','CMD','COM','CPL','CRT','CSH','DLL','EXE','FXP','GADGET','HLP','HTA','HTM','HTML','HTR','INF','INS','ISP','ITS','JS','JSE','KSH','LNK','MAD','MAF','MAG','MAM','MAQ','MAR','MAS','MAT','MAU','MAV','MAW','MDA','MDB','MDE','MDT','MDW','MDZ','MHT','MHTM','MHTML','MSC','MSI','MSP','MST','OCX','OPS','PCD','PIF','PRF','PRG','REG','SCF','SCR','SCT','SHB','SHS','TMP','URL','VB','VBE','VBS','VBX','VSMACROS','VSS','VST','VSW','WS','WSC','WSF','WSH','XSL'
$ApprovalAddress = Read-Host "Enter the email address to send all potentially compromised email to for approval"

if (!$rule) 
{
    New-TransportRule -Name $ruleName -AttachmentExtensionMatchesWords $ExtensionList -ModerateMessagebyUser $ApprovalAddress
}

else 
{
    Set-TransportRule -Identity $ruleName -AttachmentExtensionMatchesWords $ExtensionList -ModerateMessagebyUser $ApprovalAddress
}