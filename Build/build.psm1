<#
.SYNOPSIS
    Helper functions to assist with the build process of the module.
    Includes functions to set global variables, and also get testing data.
#>

function Get-SampleDNSEntries {
    $sampleFile = Join-Path -Path $ENV:BHProjectPath -ChildPath "Tests\SampleDNSEntries.json"
    if (-not (Test-Path -Path $sampleFile)) {
        throw "Unable to find DNS Sample File '$sampleFile'"
    }
    $jSON = Get-Content -Path $sampleFile | ConvertFrom-Json -ErrorAction Stop
    return $jSON
}

function Import-MyModule {
    param([switch]$Force)
    if (Get-Module -Name $Env:BHProjectName) {
        Remove-Module -Name $Env:BHProjectName -Force -ErrorAction Stop
    }
    Import-Module -Name "$Env:BHPSModuleManifest" -Global -Force:$($Force.IsPresent)
}
