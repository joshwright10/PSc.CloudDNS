function Import-PScAzureDNSZone {
    <#
.SYNOPSIS
    Creates Azure DNS Zone and Records based PScDNSRecordSet objects.

.DESCRIPTION
    Creates Azure DNS Zone and Records based PScDNSRecordSet objects.

.PARAMETER Records
    Specifies the records that are to be created.
    These must be PScDNSRecordSet objects.

.PARAMETER TenantId
    Specifies the ID of the tenant in which the records are to be created.

.PARAMETER SubscriptionId
    Specifies the ID of the Subscription in which the records are to be created.

.PARAMETER ResourceGroupName
    Specifies the resource group in which the records are to be created.

.PARAMETER TTL
    Specifies the TTL to be used for all records.
    Default value is 3600

.PARAMETER Tag
    Key-value pairs in the form of a hash table. For example: @{key0="value0";key1=$null;key2="value2"}

.EXAMPLE
    $Records = ConvertFrom-CSCZoneFile -ZoneFile "C:\Temp\example.com.txt"
    Import-PScAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600

    Creates the DNS Zone and DNS records that are passed in via the Records parameter.
    The DNS Zone and records are created in the Subscription and Resource Group specified. These must exist in advance.

.EXAMPLE
    $Records = ConvertFrom-CSCZoneFile -ZoneFile "C:\Temp\example.com.txt"
    Import-PScAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600 -Tag @{CostCentre="VALUE"}

    Creates the DNS Zone and DNS records that are passed in via the Records parameter.
    The DNS Zone and records are created in the Subscription and Resource Group specified. These must exist in advance.
    The Tag of CostCentre with a value of EXAMPLE is applied.

.LINK
    http://pscclouddns.readthedocs.io/en/latest/functions/Import-PScAzureDNSZone.md

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Records,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $false)]
        [int]$TTL,

        [Parameter(Mandatory = $false)]
        [hashtable]$Tag
    )

    begin {
        try {

            # Set default TTL if not specified
            if (-not ($PSBoundParameters["TTL"])) {
                [int]$TTL = "3600"
            }

            # Import Modules
            if (-not (Get-Module -Name "Az")) {
                Import-Module -Name "Az" -ErrorAction Stop
            }

            # Connect to Azure
            Get-AzSubscription -ErrorAction Stop | Out-Null
            Write-Verbose -Message "Connected to Azure"

            Write-Verbose -Message "Validating subscription exists: $($SubscriptionId)"
            $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop
            Write-Verbose -Message "Changing subscription context: $($Subscription.Name)"
            Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    process {
        try {
            # Loop through each unique zone passed from the $Records parameter
            # Create the Zone if it does not exist
            # Then loop through each record in that zone and create it
            $Zones = ($Records | Select-Object -Unique ZoneName).ZoneName
            $ExistsingZones = Get-AzDnsZone -ErrorAction Stop
            foreach ($Zone in $Zones) {
                try {

                    # Hashtable for creating, or updating DNS Zones
                    $Splat_AzDnsZone = @{
                        Name              = $Zone
                        ResourceGroupName = $ResourceGroupName
                        ErrorAction       = "Stop"
                    }
                    if ($PSBoundParameters["Tag"]) { [void]$Splat_AzDnsZone.Add("Tag", $Tag) }
                    if ($Zone -in $ExistsingZones.Name) {
                        Write-Verbose -Message "DNS Zone already exists for $($Zone)"
                        Set-AzDnsZone @Splat_AzDnsZone | Out-Null
                    }
                    else {
                        Write-Verbose -Message "Creating DNS Zone $($Zone) in Resource Group $($ResourceGroupName)"
                        New-AzDnsZone @Splat_AzDnsZone | Out-Null
                    }

                    # Group the records for the zone and then loop through each group to create the required records.
                    $Groups = $Records | Where-Object { $_.ZoneName -eq $Zone } | Group-Object -Property RecordType, Name
                    foreach ($RecordGroup in $Groups) {
                        $GroupedRecords = $RecordGroup.Group

                        $Name = $GroupedRecords[0].Name
                        $RecordType = $GroupedRecords[0].RecordType
                        $ZoneName = $GroupedRecords[0].ZoneName

                        $ExistingRecord = Get-AzDnsRecordSet -Name $Name -RecordType "$RecordType" -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore
                        if ($ExistingRecord) {
                            Write-Verbose -Message "Record already exists for $($Record.Name) in Zone $($Record.ZoneName)"
                            foreach ($Record in $GroupedRecords) {
                                switch ($Record.RecordType) {
                                    "A" { Add-AzDnsRecordConfig -IPv4Address $Record.Value -RecordSet $ExistingRecord | Out-Null }
                                    "AAAA" { Add-AzDnsRecordConfig -Ipv6Address $Record.Value -RecordSet $ExistingRecord | Out-Null }
                                    "CNAME" { Add-AzDnsRecordConfig -Cname $Record.Value -RecordSet $ExistingRecord | Out-Null }
                                    "MX" { Add-AzDnsRecordConfig -Exchange $Record.Value -Preference $Record.Priority -RecordSet $ExistingRecord | Out-Null }
                                    "NS" { Add-AzDnsRecordConfig -Nsdname $Record.Value -RecordSet $ExistingRecord | Out-Null }
                                    "TXT" { Add-AzDnsRecordConfig -Value $Record.Value -RecordSet $ExistingRecord | Out-Null }
                                    default {
                                        Write-Error -Message "Unable to add DNS record to existing RecordSet. Unable to determine RecordType for $($Record.Name)" -ErrorAction Stop
                                    }
                                }
                            }

                            Write-Verbose -Message "Updating existsing RecordSet: $($ExistingRecord.Id)"
                            Set-AzDnsRecordSet -RecordSet $ExistingRecord -ErrorAction Stop | Out-Null
                        }
                        else {
                            $newDnsRecord = @()
                            foreach ($Record in $GroupedRecords) {
                                $newDnsRecord += switch ($Record.RecordType) {
                                    "A" { New-AzDnsRecordConfig -IPv4Address $Record.Value ; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::A }
                                    "AAAA" { New-AzDnsRecordConfig -Ipv6Address $Record.Value ; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::AAAA }
                                    "CNAME" { New-AzDnsRecordConfig -Cname $Record.Value ; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::CNAME }
                                    "MX" { New-AzDnsRecordConfig -Exchange $Record.Value -Preference $Record.Priority; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::MX }
                                    "NS" { New-AzDnsRecordConfig -Nsdname $Record.Value ; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::NS }
                                    "SRV" { New-AzDnsRecordConfig -Priority $Record.Priority -Weight $Record.Weight -Port $Record.Port -Target $Record.Value; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::SRV }
                                    "TXT" { New-AzDnsRecordConfig -Value $Record.Value ; $RecordType = [Microsoft.Azure.Management.Dns.Models.RecordType]::TXT }
                                    default {
                                        Write-Error -Message "Unable to determine RecordType for $($Record.Name)" -ErrorAction Stop
                                    }
                                }
                            }

                            $RecordParams = @{
                                ZoneName          = [string]$ZoneName
                                Name              = [string]$Name
                                RecordType        = $RecordType
                                TTL               = $TTL
                                ResourceGroupName = [string]$ResourceGroupName
                                DnsRecords        = $newDnsRecord
                            }
                            Write-Verbose -Message "Creating new $($RecordType) record for '$($Name)' in Zone '$($ZoneName)'"
                            New-AzDnsRecordSet @RecordParams -ErrorAction Stop | Out-Null
                        }
                    }
                }
                catch {
                    $PSCmdlet.WriteError($PSItem)
                }
            }
        }
        catch {
            $PSCmdlet.WriteError($PSItem)
        }
    }
}