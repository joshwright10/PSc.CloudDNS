Describe "ConvertFrom-PScDNSCSCNSRecord" {
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
        { ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.Valid -Domain $domain -ErrorAction Stop } | Should -Not -Throw
    }

    It "should be of output type 'PScDNSRecordSet'" {
        (ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.Valid -Domain $domain -ErrorAction Stop).GetType().Name | Should -Be "PScDNSRecordSet"
    }

    It "should process single record by parameter" {
        $Record = ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.Valid -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "customdns1"
        $Record.TTL | Should -Be 0
        $Record.RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Record.Value | Should -Be "ns1-01.azure-dns.net."
        $Record.Priority | Should -Be 0
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on single record from pipeline" {
        $Record = $dnsEntries.NS.Valid | ConvertFrom-PScDNSCSCNSRecord -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "customdns1"
        $Record.TTL | Should -Be 0
        $Record.RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Record.Value | Should -Be "ns1-01.azure-dns.net."
        $Record.Priority | Should -Be 0
        $Record.Weight | Should -Be 0
        $Record.Port | Should -Be 0
    }

    It "should work on array of InputObjects" {
        $Records = ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.Array -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "customdns1"
        $Records[0].TTL | Should -Be 0
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Records[0].Value | Should -Be  "ns1-01.azure-dns.net."
        $Records[0].Priority | Should -Be 0
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "customdns2"
        $Records[1].TTL | Should -Be 250
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Records[1].Value | Should -Be "ns2-01.azure-dns.net."
        $Records[1].Priority | Should -Be 1
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should work on array object from pipeline" {
        $Records = $dnsEntries.NS.Array | ConvertFrom-PScDNSCSCNSRecord -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "customdns1"
        $Records[0].TTL | Should -Be 0
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Records[0].Value | Should -Be  "ns1-01.azure-dns.net."
        $Records[0].Priority | Should -Be 0
        $Records[0].Weight | Should -Be 0
        $Records[0].Port | Should -Be 0

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "customdns2"
        $Records[1].TTL | Should -Be 250
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::NS)
        $Records[1].Value | Should -Be "ns2-01.azure-dns.net."
        $Records[1].Priority | Should -Be 1
        $Records[1].Weight | Should -Be 0
        $Records[1].Port | Should -Be 0
    }

    It "should throw error for MX record input" {
        { ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.MX.Valid -Domain $domain -ErrorAction Stop } | Should -Throw
    }

    It "should not process netnames records" {
        $Record = ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.Netnames -Domain $domain
        $Record | Should -BeNullOrEmpty
    }

    It "should not process root NS records" {
        $Record = ConvertFrom-PScDNSCSCNSRecord -InputObject $dnsEntries.NS.RootRecord -Domain $domain
        $Record | Should -BeNullOrEmpty
    }

}