Describe "ConvertFrom-PScDNSCSCMXRecord" {
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
        { ConvertFrom-PScDNSCSCMXRecord -InputObject $dnsEntries.MX.Valid -Domain $domain -ErrorAction Stop } | Should -Not -Throw
    }

    It "should be of output type 'PScDNSRecordSet'" {
        (ConvertFrom-PScDNSCSCMXRecord -InputObject $dnsEntries.MX.Valid -Domain $domain -ErrorAction Stop).GetType().Name | Should -Be "PScDNSRecordSet"
    }

    It "should process single record by parameter" {
        $Record = ConvertFrom-PScDNSCSCMXRecord -InputObject $dnsEntries.MX.Valid -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "@"
        $Record.TTL | Should -Be 300
        $Record.RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Record.Value | Should -Be "eu-smtp-inbound-1.mimecast.com."
        $Record.Priority | Should -Be 10
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on single record from pipeline" {
        $Record = $dnsEntries.MX.Valid | ConvertFrom-PScDNSCSCMXRecord -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "@"
        $Record.TTL | Should -Be 300
        $Record.RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Record.Value | Should -Be "eu-smtp-inbound-1.mimecast.com."
        $Record.Priority | Should -Be 10
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on array of InputObjects" {
        $Records = ConvertFrom-PScDNSCSCMXRecord -InputObject $dnsEntries.MX.Array -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "@"
        $Records[0].TTL | Should -Be 300
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Records[0].Value | Should -Be "eu-smtp-inbound-1.mimecast.com."
        $Records[0].Priority | Should -Be 10
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "@"
        $Records[1].TTL | Should -Be 650
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Records[1].Value | Should -Be "eu-smtp-inbound-2.mimecast.com."
        $Records[1].Priority | Should -Be 20
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should work on array object from pipeline" {
        $Records = $dnsEntries.MX.Array | ConvertFrom-PScDNSCSCMXRecord -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "@"
        $Records[0].TTL | Should -Be 300
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Records[0].Value | Should -Be "eu-smtp-inbound-1.mimecast.com."
        $Records[0].Priority | Should -Be 10
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "@"
        $Records[1].TTL | Should -Be 650
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::MX)
        $Records[1].Value | Should -Be "eu-smtp-inbound-2.mimecast.com."
        $Records[1].Priority | Should -Be 20
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should throw error for A record input" {
        { ConvertFrom-PScDNSCSCMXRecord -InputObject $dnsEntries.A.Valid -Domain $domain -ErrorAction Stop } | Should -Throw
    }

}