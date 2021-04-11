Describe "ConvertFrom-PScDNSCSCSRVRecord" {
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
        { ConvertFrom-PScDNSCSCSRVRecord -InputObject $dnsEntries.SRV.Valid -Domain $domain -ErrorAction Stop } | Should -Not -Throw
    }

    It "should be of output type 'PScDNSRecordSet'" {
        (ConvertFrom-PScDNSCSCSRVRecord -InputObject $dnsEntries.SRV.Valid -Domain $domain -ErrorAction Stop).GetType().Name | Should -Be "PScDNSRecordSet"
    }

    It "should process single record by parameter" {
        $Record = ConvertFrom-PScDNSCSCSRVRecord -InputObject $dnsEntries.SRV.Valid -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "_sip._tls"
        $Record.TTL | Should -Be 3600
        $Record.RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Record.Value | Should -Be "sipdir.online.lync.com."
        $Record.Priority | Should -Be 100
        $Record.Weight | Should -Be 1
        $Record.Port | Should -Be 443
    }

    It "should work on single record from pipeline" {
        $Record = $dnsEntries.SRV.Valid | ConvertFrom-PScDNSCSCSRVRecord -Domain $domain

        $Record.ZoneName | Should -Be "example.com"
        $Record.Name | Should -Be "_sip._tls"
        $Record.TTL | Should -Be 3600
        $Record.RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Record.Value | Should -Be "sipdir.online.lync.com."
        $Record.Priority | Should -Be 100
        $Record.Weight | Should -Be 1
        $Record.Port | Should -Be 443
    }

    It "should work on array of InputObjects" {
        $Records = ConvertFrom-PScDNSCSCSRVRecord -InputObject $dnsEntries.SRV.Array -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "_sip._tls"
        $Records[0].TTL | Should -Be 3600
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Records[0].Value | Should -Be  "sipdir.online.lync.com."
        $Records[0].Priority | Should -Be 100
        $Records[0].Weight | Should -Be 1
        $Records[0].Port | Should -Be 443

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "_sipfederationtls._tcp"
        $Records[1].TTL | Should -Be 0
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Records[1].Value | Should -Be "sipfed.online.lync.com."
        $Records[1].Priority | Should -Be 100
        $Records[1].Weight | Should -Be 1
        $Records[1].Port | Should -Be 5061
    }

    It "should work on array object from pipeline" {
        $Records = $dnsEntries.SRV.Array | ConvertFrom-PScDNSCSCSRVRecord -Domain $domain
        ($Records | Measure-Object).Count | Should -Be 2

        # Test record 1 from the array
        $Records[0].ZoneName | Should -Be "example.com"
        $Records[0].Name | Should -Be "_sip._tls"
        $Records[0].TTL | Should -Be 3600
        $Records[0].RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Records[0].Value | Should -Be  "sipdir.online.lync.com."
        $Records[0].Priority | Should -Be 100
        $Records[0].Weight | Should -Be 1
        $Records[0].Port | Should -Be 443

        # Test record 2 from the array
        $Records[1].ZoneName | Should -Be "example.com"
        $Records[1].Name | Should -Be "_sipfederationtls._tcp"
        $Records[1].TTL | Should -Be 0
        $Records[1].RecordType | Should -Be ([PScDNSRecordType]::SRV)
        $Records[1].Value | Should -Be "sipfed.online.lync.com."
        $Records[1].Priority | Should -Be 100
        $Records[1].Weight | Should -Be 1
        $Records[1].Port | Should -Be 5061
    }

    It "should throw error for MX record" {
        { ConvertFrom-PScDNSCSCSRVRecord -InputObject $dnsEntries.MX.Valid -Domain $domain -ErrorAction Stop } | Should -Throw
    }

}