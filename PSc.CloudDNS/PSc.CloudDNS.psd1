@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSc.CloudDNS.psm1'

    # Version number of this module.
    ModuleVersion        = '0.1.0'

    # Supported PSEditions
    CompatiblePSEditions = 'Desktop'

    # ID used to uniquely identify this module
    GUID                 = 'cf17a06b-f97a-4181-8eca-08c6bd363b39'

    # Author of this module
    Author               = 'Josh Wright'

    # Copyright statement for this module
    Copyright            = '(c) 2020 Josh Wright  All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'PowerShell module for working with DNS cloud migration activities'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess     = @('Classes\PScDNSRecordSet.ps1')

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        "ConvertFrom-PScCSCZoneFile",
        "Import-PScAzureDNSZone"
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DNS', 'Azure', 'CSC')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/joshwright10/PSc.CloudDNS/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/joshwright10/PSc.CloudDNS'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/joshwright10/PSc.CloudDNS/blob/master/RELEASE.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}