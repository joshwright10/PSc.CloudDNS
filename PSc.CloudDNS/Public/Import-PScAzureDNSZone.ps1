function Import-PScAzureDNSZone {
    <#
.SYNOPSIS
    Creates Azure DNS Zone and Records based on the output of the ConvertFrom-PScCSCZoneFile function

.PARAMETER Records
    Specifies the records that are to be created.
    This must be a PSObject in the following format:

        ZoneName   : example.com
        Name       : www
        TTL        :
        RecordType : A
        Value      : 1.1.1.1
        Priority   :
        Weight     :
        Port       :

        ZoneName   : example.com
        Name       : _sipfederationtls._tcp
        TTL        :
        RecordType : SRV
        Value      : sipfed.online.lync.com.
        Priority   : 100
        Weight     : 1
        Port       : 5061

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
    PS C:\> $Records = ConvertFrom-CSCZoneFile.ps1 -ZoneFile "C:\Temp\example.com.txt"
    PS C:\> Import-EMAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600

    Creates the DNS Zone and DNS records that are passed in via the Records parameter.
    The DNS Zone and records are created in the Subscription and Resource Group specified. These must exist in advance.

.EXAMPLE
    PS C:\> $Records = ConvertFrom-CSCZoneFile.ps1 -ZoneFile "C:\Temp\example.com.txt"
    PS C:\> Import-EMAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600 -Tag @{CostCentre="VALUE"}

    Creates the DNS Zone and DNS records that are passed in via the Records parameter.
    The DNS Zone and records are created in the Subscription and Resource Group specified. These must exist in advance.
    The Tag of CostCentre with a value of EXAMPLE is applied.

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

                    # Loop through each record in the zone and create the required records
                    foreach ($Record in ($Records | Where-Object { $_.ZoneName -eq $Zone })) {

                        $ExistingRecord = Get-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore
                        if ($ExistingRecord) {
                            Write-Verbose -Message "Record already exists for $($Record.Name) in Zone $($Record.ZoneName)"
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

                            Write-Verbose -Message "Updating existsing RecordSet: $($ExistingRecord.Id)"
                            Set-AzDnsRecordSet -RecordSet $ExistingRecord -ErrorAction Stop | Out-Null

                        }
                        else {
                            switch ($Record.RecordType) {
                                "A" { $DnsRecord = New-AzDnsRecordConfig -IPv4Address $Record.Value }
                                "AAAA" { $DnsRecord = New-AzDnsRecordConfig -Ipv6Address $Record.Value }
                                "CNAME" { $DnsRecord = New-AzDnsRecordConfig -Cname $Record.Value }
                                "MX" { $DnsRecord = New-AzDnsRecordConfig -Exchange $Record.Value -Preference $Record.Priority }
                                "NS" { $DnsRecord = New-AzDnsRecordConfig -Nsdname $Record.Value }
                                "SRV" { $DnsRecord = New-AzDnsRecordConfig -Priority $Record.Priority -Weight $Record.Weight -Port $Record.Port -Target $Record.Value }
                                "TXT" { $DnsRecord = New-AzDnsRecordConfig -Value $Record.Value }
                                default {
                                    Write-Error -Message "Unable to determine RecordType for $($Record.Name)" -ErrorAction
                                }
                            }

                            $RecordParams = @{
                                ZoneName          = $Record.ZoneName
                                Name              = $Record.Name
                                RecordType        = $Record.RecordType
                                TTL               = $TTL
                                ResourceGroupName = $ResourceGroupName
                                DnsRecords        = $DnsRecord
                            }
                            Write-Verbose -Message "Creating new $($Record.RecordType) record for $($Record.Name) in Zone $($Record.ZoneName)"
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