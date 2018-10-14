#this mail flow rule will prepend an HTML warning banner to any message originating from outside the organization from a display name which matches an internal employee's name
#note that this warning will appear for message sent from employee's personal email accounts, or if the employee has a relatively common name

#import required modules and connect to Office 365 if not already loaded
if (!(Get-Module msonline))
    {
    Import-Module msonline
    $cred = Get-Credential
    Connect-MsolService -Credential $cred
    $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $s
    }

#Set variables for the rule name and the HTML banner
$ruleName = "External Senders with matching Display Names"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#910A19;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#FDF2F4;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message was sent from outside the company by someone with a display name matching a user in your organisation. Please do not click links or open attachments unless you sent it, or you recognize the source of this email and know the content is safe. Please email IT helpdesk if you have any questions. <o:p></o:p></span></p></div></td></tr></table>"
 
#Pop a credential window to connect to 365 
$credentials = Get-Credential
 
#Create and connect to 365 session 
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ -ConfigurationName Microsoft.Exchange -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
 
#Variables for checking if the rule already exists, and getting all employee names 
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
$displayNames = (Get-Mailbox -ResultSize Unlimited).DisplayName
 
#if the rule doesn't exist, create it 
if (!$rule) 
{
    Write-Host "Rule not found, creating rule" -ForegroundColor Green
    New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
}

#if the rule does exist, update the rule with current employee displaynames
else 
{
    Write-Host "Rule found, updating rule with current employee list" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
}

#Disconnect 365 session
Remove-PSSession $Session