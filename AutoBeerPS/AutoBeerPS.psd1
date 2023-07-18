﻿@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'AutoBeerPS.psm1'
    
    # Version number of this module.
    ModuleVersion     = '1.0.0'
    
    # Supported PSEditions
    # CompatiblePSEditions = @()
    
    # ID used to uniquely identify this module
    GUID              = '718bbc43-7e0d-4acb-acee-fc946a868b09'
    
    # Author of this module
    Author            = 'Jan-Hendrik Peters'
    
    # Company or vendor of this module
    CompanyName       = 'Jan-Hendrik Peters'
    
    # Copyright statement for this module
    Copyright         = '(c) Jan-Hendrik Peters. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description       = 'AutoBeer API to work with Tilt sensor'
    
    # Minimum version of the PowerShell engine required by this module
    # PowerShellVersion = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        'Pode'
    )
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @('bin\my.dll')
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-Beer'
        'New-Beer'
        'Set-Beer'
        'Remove-Beer'
        'Get-BeerMeasurementInfo'
        'New-BeerMeasurementInfo'
        'Set-BeerMeasurementInfo'
        'Remove-BeerMeasurementInfo'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    # CmdletsToExport   = '*'
    
    # Variables to export from this module
    # VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    # AliasesToExport   = '*'
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    # FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            # ProjectUri = ''
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
            # Prerelease string of this module
            # Prerelease = ''
    
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false
    
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
    
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
}