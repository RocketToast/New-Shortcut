
function New-ShortCut {
<#
.SYNOPSIS

Creates a shortcut on your computer.
  - .lnk for any shortcut with a driveletter
  - .url for shortcuts to a website / fileshare

.DESCRIPTION

This function will make a shortcut on your system. If the TargetPath begins with any driveletter
(ex: C:\, Z:\, A:\) then a `.lnk` shortcut is created in your ShortcutPath location. If your TargetPath
begins with `http` or a double backslash `\\` then a `.url` type shortcut is created.

.PARAMETER TargetPath

This is where the shortcut is going to.
**MUST BEGIN WITH a driveletter (ex: F:\) or `http` or two backslashes `\\`!**

.PARAMETER ShortcutPath

This is where shortcuts will be located.

.PARAMETER Name

This is the name of your shortcut.

.PARAMETER Description

This is the description shown for the created shortcut.

.PARAMETER IconPath

This is the location of your `.ico` or `.dll` where your shortcut icon is located.
If your pointing to a `.dll` then you'll need to know the IconIndex number to get the correct
icon file.

.PARAMETER IconIndex

You'll need the IconIndex parameter in conjunction with IconPath. Default is 0.

.EXAMPLE

This is an example to make a shortcut on a users desktop to Sysinternals Process Explorer
with a microchip icon from `SHELL32.dll`.

$ShortcutSplat = @{
    TargetPath   = '\\live.sysinternals.com\tools\procexp64.exe'
    ShortcutPath = "$env:USERPROFILE\Desktop\"
    Name         = 'Process Explorer'
    IconPath     = "$env:SystemRoot\System32\SHELL32.dll"
    IconIndex    = 12
}
New-ShortCut @ShortcutSplat

.EXAMPLE

The example is making a shortcut to the `C:\Windows\` folder in the documents folder.

New-Shortcut -Targetpath 'C:\Windows' -ShortcutPath "$env:USERPROFILE\Documents\" -Name "Windows Folder"

#>
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
        [int]$IconIndex = 0
    )

    try
    {
        # Determine extension based on target type
        $ext = if ( $TargetPath -match '^\D\:\\' ) {
            '.lnk'
        } elseif ( $TargetPath -match '^http' -or $TargetPath -match '\\\\' ) {
            '.url'
        } else {
            throw "Your shortcut MUST begin with a driveletter (ex: C:\), http or \\ !"
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
        IDList=
        URL=$TargetPath
        IconIndex=$IconIndex
        HotKey=0
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

