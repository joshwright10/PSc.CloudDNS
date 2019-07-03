function ConvertFrom-PScCSCZoneFile {
    <#
.SYNOPSIS
    Converts each entry in a DNS Zone File downloaded from the CSC domain Management portal into an individual object.

.PARAMETER ZoneFile
    Specifies the CSC Zone file to be converted.
    One or more zone files can be passed at the same time.

.EXAMPLE
    PS C:\> ConvertFrom-PScCSCZoneFile.ps1 -ZoneFile "C:\Temp\example.com.txt"

    Reads the Zone File and converts each entry into a PSObject.

.EXAMPLE
    PS C:\> ConvertFrom-PScCSCZoneFile.ps1 -ZoneFile "C:\Temp\example.com.txt","C:\Temp\example2.com.txt"

    Reads the Zone Files and converts each entry into a PSObject.

.INPUTS
    Zone file from the CSC Domain Management Portal.
.OUTPUTS
    PSObject

.NOTES
    The CSC Zone file does not contain URL Forwarding Records, so these will need to be handled separately.
    Any Root NS records will be ignored.
    Any NS record that refers to netnames.net will be ignored.

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
                $Records = @()
                foreach ($Entry in ([System.IO.File]::ReadLines($File.FullName))) {

                    $RegexResult = $null
                    $Record = $null

                    $LineNumber++
                    Write-Verbose -Message "Processing line: $($LineNumber)"
                    Switch ($Entry) {

                        { [string]::IsNullOrEmpty($Entry) } {
                            Write-Verbose -Message "Line $($LineNumber) is empty"
                        }

                        { $Entry -match "^\`$ORIGIN" } {
                            $Domain = ($Entry | Select-String -Pattern "^\`$ORIGIN\s(.+)\.").Matches[0].Groups[1].Value
                            Write-Verbose -Message "Domain found on line $($LineNumber) - ZoneName is $($Domain)"
                        }

                        { $Entry -match "^\`$TTL" } {
                            Write-Verbose -Message "Ignoring domain TTL value on line $($LineNumber)"
                        }

                        { $Entry -match "\sSOA\s|\;\Wserial|\;\Wrefresh|\;\Wretry|\;\Wexpire|\;\Wminimum\sTTL|\)" } {
                            Write-Verbose -Message "Ignoring SOA record"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\s(A)\s" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(A)\W(.+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "A"
                                Value      = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                Priority   = $null
                                Weight     = $null
                                Port       = $null
                            }
                            $Records += $Record
                            Write-Verbose -Message "A Record found on line $($LineNumber)"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(CNAME)" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(CNAME)\W(.+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "CNAME"
                                Value      = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                Priority   = $null
                                Weight     = $null
                                Port       = $null
                            }
                            $Records += $Record
                            Write-Verbose -Message "CNAME Record found on line $($LineNumber)"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(MX)" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(MX)\W(.+)\W([0-9]+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "MX"
                                Value      = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                Priority   = $RegexResult.Matches[0].Groups[5].Value.Trim()
                                Weight     = $null
                                Port       = $null
                            }
                            $Records += $Record
                            Write-Verbose -Message "MX Record found on line $($LineNumber)"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(NS)" } {

                            if ($Entry -match "(.+)\W([0-9]+)?\W(NS)\W(.+).+netnames\.net") {
                                Write-Verbose -Message "Ignoring netnames NS records"
                            }
                            elseif ($Entry -match "^@") {
                                Write-Verbose -Message "Root NS records"
                            }
                            else {
                                $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(NS)\W(.+)\W([0-9]+)")
                                $Record = [PSCustomObject]@{
                                    ZoneName   = $Domain
                                    Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                    TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                    RecordType = "NS"
                                    Value      = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                    Priority   = $RegexResult.Matches[0].Groups[5].Value.Trim()
                                    Weight     = $null
                                    Port       = $null
                                }
                                $Records += $Record
                                Write-Verbose -Message "NS Record found on line $($LineNumber)"
                            }
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(TXT)" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(TXT)\W(.+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "TXT"
                                Value      = $RegexResult.Matches[0].Groups[4].Value.Trim().TrimStart('"').TrimEnd('"')
                                Priority   = $null
                                Weight     = $null
                                Port       = $null
                            }
                            $Records += $Record
                            Write-Verbose -Message "TXT Record found on line $($LineNumber)"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\W(SRV)" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(SRV)\W([0-9]+)\W([0-9]+)\W([0-9]+)\W(.+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "SRV"
                                Value      = $RegexResult.Matches[0].Groups[7].Value.Trim()
                                Priority   = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                Weight     = $RegexResult.Matches[0].Groups[5].Value.Trim()
                                Port       = $RegexResult.Matches[0].Groups[6].Value.Trim()
                            }
                            $Records += $Record
                            Write-Verbose -Message "SRV Record found on line $($LineNumber)"
                        }

                        { $Entry -match "(.+)\W([0-9]+)?\s(AAAA)\s" } {

                            $RegexResult = ($Entry | Select-String -Pattern "(.+)\W([0-9]+)?\W(AAAA)\W(.+)")
                            $Record = [PSCustomObject]@{
                                ZoneName   = $Domain
                                Name       = $RegexResult.Matches[0].Groups[1].Value.Trim()
                                TTL        = $RegexResult.Matches[0].Groups[2].Value.Trim()
                                RecordType = "AAAA"
                                Value      = $RegexResult.Matches[0].Groups[4].Value.Trim()
                                Priority   = $null
                                Weight     = $null
                                Port       = $null
                            }
                            $Records += $Record
                            Write-Verbose -Message "AAAA Record found on line $($LineNumber)"
                        }


                        default {
                            Write-Error -Message "Unable to process line ($LineNumber)" -ErrorAction Stop
                        }

                    } # Switch Statement
                }

                #return records
                $Records

            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}