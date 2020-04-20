Describe "ConvertFrom-PScDNSCSCTXTRecord" {
    BeforeAll {
        $Script:moduleName = $ENV:BHProjectName
        $Script:modulePath = $ENV:BHModulePath

        $functionName = (Split-Path -Path $PSCommandPath -Leaf) -replace "\.Tests.ps1$", ""
        $functionPath = Join-Path -Path $modulePath -ChildPath "Private\CSC\$functionName.ps1"

        Import-MyModule
        Get-ChildItem -File -Path "$modulePath\Classes\*" -Recurse | ForEach-Object { . "$($_.FullName)" }

        . "$functionPath"
        $Script:dnsEntries = Get-SampleDNSEntries
        $Script:domain = "example.com"
    }

    It "should not not have errors" {
        { ConvertFrom-PScDNSCSCTXTRecord -InputObject $dnsEntries.TXT.Valid -Domain $domain -ErrorAction Stop } | Should -Not -Throw
    }

    It "should be of output type 'PScDNSRecordSet'" {
        (ConvertFrom-PScDNSCSCTXTRecord -InputObject $dnsEntries.TXT.Valid -Domain $domain -ErrorAction Stop).GetType().Name | Should -Be "PScDNSRecordSet"
    }

    It "should process single record by parameter" {
        $Record = ConvertFrom-PScDNSCSCTXTRecord -InputObject $dnsEntries.TXT.Valid -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "@"
        $Record.TTL | Should -Be 300
        $Record.RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Record.Value | Should -Be "v=spf1 include:eu._netblocks.mimecast.com include:spf.protection.outlook.com  -all"
        $Record.Priority | Should -Be 0
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on single record from pipeline" {
        $Record = $dnsEntries.TXT.Valid | ConvertFrom-PScDNSCSCTXTRecord -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "@"
        $Record.TTL | Should -Be 300
        $Record.RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Record.Value | Should -Be "v=spf1 include:eu._netblocks.mimecast.com include:spf.protection.outlook.com  -all"
        $Record.Priority | Should -Be 0
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on array of InputObjects" {
        $Records = ConvertFrom-PScDNSCSCTXTRecord -InputObject $dnsEntries.TXT.Array -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "@"
        $Records[0].TTL | Should -Be 300
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Records[0].Value | Should -Be  "v=spf1 include:eu._netblocks.mimecast.com include:spf.protection.outlook.com  -all"
        $Records[0].Priority | Should -Be 0
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "@"
        $Records[1].TTL | Should -Be 300
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Records[1].Value | Should -Be "MS=ms88642848"
        $Records[1].Priority | Should -Be 0
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should work on array object from pipeline" {
        $Records = $dnsEntries.TXT.Array | ConvertFrom-PScDNSCSCTXTRecord -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "@"
        $Records[0].TTL | Should -Be 300
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Records[0].Value | Should -Be  "v=spf1 include:eu._netblocks.mimecast.com include:spf.protection.outlook.com  -all"
        $Records[0].Priority | Should -Be 0
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "@"
        $Records[1].TTL | Should -Be 300
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::TXT)
        $Records[1].Value | Should -Be "MS=ms88642848"
        $Records[1].Priority | Should -Be 0
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should throw error for MX record" {
        { ConvertFrom-PScDNSCSCTXTRecord -InputObject $dnsEntries.MX.Valid -Domain $domain -ErrorAction Stop } | Should -Throw
    }

}