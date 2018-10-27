#Sinkholes all DNS requests to country code top level domains (ccTLDs)
#Sometimes companies use ccTLDs even when they're not supposed to.
#Super hip startups and app websites sometimes use .io (Indian Ocean)
#Many URL shortners use ccTLDs (youtu.be, bit.ly) like fools
#Remove any ccTLDs that you think have legitmate uses for your users
#Keep in mind this is easily circumvented by changing the DNS server for the NIC or the for the request itself
#This is only to protect end-users, like how those plastic wall outlet coverings protect toddlers from frying even though they're easy to remove

#Enter "." for local machine, or enter the authoritative DNS server FQDN
$DNSServer = "dns.domain.local"
#Enter the IP for the sinkhole destination
$Sinkhole = "0.0.0.0"
#Enter your domain root zone
$Zone = "domain.local"

$r = Invoke-Webrequest https://www.iana.org/domains/root/db
$FullDomainList = $r.Links.InnerHTML | Where-Object {$_ -like "*.*"}
$CountryOnlyDomainList = @()

foreach ($Domain in $FullDomainList)
{
    if ($Domain.Length -eq 3)
    {
        $CountryOnlyDomainList += $Domain 
    }
}

#Domain list
$DomainList = $CountryOnlyDomainList.Trim(".")

#Loop through each line of the txt file...
foreach ($ccTLD in $DomainList)
{
    #... and add each line as a new zone...  
    dnscmd.exe $DNSServer /zoneadd $ccTLD /dsprimary 
    #and also create a wildcard A record to the sinkhole
    dnscmd.exe $DNSServer /recordadd $ccTLD * A $Sinkhole
}
