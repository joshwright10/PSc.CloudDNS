function ConvertFrom-PScDNSCSCMXRecord {
    <#
    .SYNOPSIS
        Converts a CSC MX Record into one or more PScDNSRecordSet objects.

    .DESCRIPTION
        The ConvertFrom-PScDNSCSCMXRecord function parses a line from a CSC zone export and converts it into a PScDNSRecordSet object.

    .PARAMETER InputObject
        Specifies the line from the CSC DNS export file to be processes.

    .PARAMETER Domain
        Specifies domain name of the related record set, e.g. example.com

    .EXAMPLE
        PS C:\> ConvertFrom-PScDNSCSCMXRecord -InputObject $Records -Domain "example.com"

    .INPUTS
        System.String

    .OUTPUTS
        PScDNSRecordSet

    #>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = "Line from CSC DNS export file",
            ValuefromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $InputObject,

        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = "Domain name of related records (e.g. example.com)")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Domain

    )
    process {
        foreach ($Entry in $InputObject) {

            $RegexResult = $null
            $RegexResult = $Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(MX)\W(.+)\W([0-9]+)"

            if (-not ($RegexResult)) {
                throw  "Entry '$Entry' is not of type 'MX'"
            }

            $ZoneName = $Domain
            $Name = $RegexResult.Matches[0].Groups[1].Value.Trim()
            $TTL = $RegexResult.Matches[0].Groups[2].Value.Trim()
            $RecordType = [PScDNSRecordType]::MX
            $Value = $RegexResult.Matches[0].Groups[4].Value.Trim()
            $Priority = $RegexResult.Matches[0].Groups[5].Value.Trim()
            $Weight = $null
            $Port = $null

            [PScDNSRecordSet]::new($ZoneName, $Name, $TTL, $RecordType, $Value, $Priority, $Weight, $Port)

        }
    }
}