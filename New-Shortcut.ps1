function New-ShortCut {
    [CmdletBinding( DefaultParameterSetName = "Shortcut" )]
    param (
        [Parameter( Mandatory        = $true,
                    HelpMessage      = "File or Folder to link to.",
                    ParameterSetName = "Shortcut" )]
        [Parameter( Mandatory        = $true,
                    ParameterSetName = "Icon" )]
        [string]$TargetPath,

        [Parameter( Mandatory        = $true,
                    HelpMessage      = "Where a shortcut will be placed.",
                    ParameterSetName = "Shortcut" )]
        [Parameter( Mandatory        = $true,
                    ParameterSetName = "Icon" )]
        [string]$ShortcutPath,

        [Parameter( Mandatory        = $true,
                    HelpMessage      = "Name of shortcut.",
                    ParameterSetName = "Shortcut" )]
        [Parameter( Mandatory        = $true,
                    ParameterSetName = "Icon" )]
        [string]$Name,

        [Parameter( HelpMessage = "Short description of the shortcut." )]
        [string]$Description,

        [Parameter( Mandatory        = $true,
                    ParameterSetName = "Icon" )]
        [string]$IconPath,

        [Parameter( Mandatory        = $true,
                    ParameterSetName = "Icon" )]
        [int]$IconIndex
    )

    try
    {
        # Determine extension based on target type
        $ext = if ( $TargetPath -match '^\D\:\\' ) {
            '.lnk'
        } elseif ( $TargetPath -match '^http' -or $TargetPath -match '\\\\' ) {
            '.url'
        }

        # Ensure shortcut path ends with backslash
        if ( $ShortcutPath -notmatch '\\$' ) {
            $ShortcutPath += '\'
        }

        $Full = "$ShortcutPath$Name$ext"

        # Prevent overwriting
        if ( Test-Path $Full ) {
            throw "Shortcut '$Full' already exists."
        }

        if ( $ext -eq '.lnk' ) {

            # Create .lnk shortcut
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($Full)
            $Shortcut.TargetPath = $TargetPath

            if ( $Description ) {
                $Shortcut.Description = $Description
            }
            
            if ( $IconPath ) {
                $Shortcut.IconLocation = "$IconPath,$IconIndex"
            }

            $Shortcut.Save()
            
        } else {

            # Create .url shortcut

    $URLFileContent = @"
        [InternetShortcut]
        URL=$TargetPath
        IconIndex=$IconIndex
        IconFile=$IconPath
"@

    $NewItemSplat = @{
        Path     = $ShortcutPath
        Name     = "$Name$Ext"
        ItemType = 'File'
        Value    = $URLFileContent
        Force    = $true
            }
    [VOID](New-Item @NewItemSplat)
        }

        Write-Verbose "Shortcut created successfully at: $Full"
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    } # End Try / Catch
} # End Function

