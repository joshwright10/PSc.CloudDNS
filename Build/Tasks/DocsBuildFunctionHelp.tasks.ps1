<#
Create and update help documentation
#>
task DocsBuildFunctionHelp {

    if (-not (Test-Path -Path "$env:BHProjectPath\docs\functions")) {
        [void](New-Item -Path "$env:BHProjectPath\docs\functions" -ItemType Directory -Force)
    }

    Import-Module -Name $env:BHPSModuleManifest -Force
    try {
        [void](Update-MarkdownHelpModule -Path "$Env:BHProjectPath\docs\functions" -Force -ErrorAction Stop)
    }
    catch {
        # If the error was caused by not knowing the module name, create the initial help markdown files
        if ($_.Exception.Message -match "Cannot determine module name") {
            [void](New-MarkdownHelp -Module $env:BHProjectName -OutputFolder "$env:BHProjectPath\docs\functions" -UseFullTypeName)
        }
        else {
            throw $_
        }
    }
}
