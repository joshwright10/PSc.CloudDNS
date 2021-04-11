function ConvertFrom-PScCSCZoneFile {
    <#
.SYNOPSIS
    Converts each entry in a DNS Zone File downloaded from the CSC domain Management portal into an individual object.

.DESCRIPTION
    Converts each entry in a DNS Zone File downloaded from the CSC domain Management portal into an individual object.

.PARAMETER ZoneFile
    Specifies the CSC Zone file to be converted.
    One or more zone files can be passed at the same time.

.EXAMPLE
    ConvertFrom-PScCSCZoneFile -ZoneFile "C:\Temp\example.com.txt"

    Reads the Zone File and converts each entry into a PScDNSRecordSet object.

.EXAMPLE
    ConvertFrom-PScCSCZoneFile -ZoneFile "C:\Temp\example.com.txt","C:\Temp\example2.com.txt"

    Reads the Zone Files and converts each entry into a PScDNSRecordSet object.

.INPUTS
    TXT zone file export from the CSC Domain Management Portal.

.OUTPUTS
    PScDNSRecordSet

.NOTES
    The CSC Zone file does not contain URL Forwarding Records, so these will need to be handled separately.
    Any Root NS records will be ignored.
    Any NS record that refers to netnames.net will be ignored.

.LINK
    http://pscclouddns.readthedocs.io/en/latest/functions/ConvertFrom-PScCSCZoneFile.md

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                if (-Not ($_ | Test-Path) ) {
                    throw "File or folder does not exist."
                }
                if (-Not ($_ | Test-Path -PathType Leaf) ) {
                    throw "The Path argument must be a file. Folder paths are not allowed."
                }
                return $true
            })]
        [System.IO.FileInfo[]]$ZoneFile
    )

    process {
        foreach ($File in $ZoneFile) {
            try {

                Write-Verbose -Message "Processing Zone File: $($File.FullName)"
                [int]$LineNumber = 0
                [PScDNSRecordSet[]]$Records = @()
                foreach ($Entry in ([System.IO.File]::ReadLines($File.FullName))) {

                    $LineNumber++
                    Write-Verbose -Message "Processing line: $($LineNumber)"
                    Switch ($Entry) {

                        { [string]::IsNullOrEmpty($Entry) } {
                            Write-Verbose -Message "Line $($LineNumber) is empty"
                            continue
                        }

                        { $Entry -match "^\`$ORIGIN" } {
                            $Domain = ($Entry | Select-String -Pattern "^\`$ORIGIN\s(.+)\.").Matches[0].Groups[1].Value
                            Write-Verbose -Message "Domain found on line $($LineNumber) - ZoneName is $($Domain)"
                            continue
                        }

                        { $Entry -match "^\`$TTL" } {
                            Write-Verbose -Message "Ignoring domain TTL value on line $($LineNumber)"
                            continue
                        }

                        { $Entry -match "\sSOA\s|\;\Wserial|\;\Wrefresh|\;\Wretry|\;\Wexpire|\;\Wminimum\sTTL|\)" } {
                            Write-Verbose -Message "Ignoring SOA record"
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\s(A)\s" } {
                            Write-Verbose -Message "A Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCARecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(CNAME)" } {
                            Write-Verbose -Message "CNAME Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCCNAMERecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(MX)" } {
                            Write-Verbose -Message "MX Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCMXRecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(NS)" } {
                            Write-Verbose -Message "NS Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCNSRecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(TXT)" } {
                            Write-Verbose -Message "TXT Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCTXTRecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(SRV)" } {
                            Write-Verbose -Message "SRV Record found on line $($LineNumber)"
                            $Records += ConvertFrom-PScDNSCSCSRVRecord -InputObject $Entry -Domain $Domain
                            continue
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\s(AAAA)\s" } {

                            $notImplementedException = [System.NotImplementedException]::new()
                            Write-Error -Exception $notImplementedException -Message "AAAA record found on line $lineNumber. Feature not implemented to process 'AAAA' records."
                            continue
                        }

                        default {
                            Write-Error -Message "Unable to process line ($LineNumber)" -ErrorAction Stop
                        }
                    }
                }

                #return records
                $Records

            }
            catch {
                $PSCmdlet.WriteError($PSItem)
            }
        }
    }
}