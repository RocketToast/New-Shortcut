# New-Shortcut
This is an Advanced Powershell Function to create a new shortcut in Windows.

Depending on the beginning of the TargetPath parameter will the function make either a `.url` or `.lnk`.
- If it begins with a drive path ex: `C:\` or `H:\` it'll make a `.lnk` shortcut.
- If it begins with a `http` or `\\` it'll make a `.url` shortcut.

For the icon:
- For a custom icon, specify the path to your icon file.
- If you're going to use one of the default icons from `SHELL32.dll` change your IconIndex number to your desired icon pictured [HERE](https://renenyffenegger.ch/development/Windows/PowerShell/examples/WinAPI/ExtractIconEx/shell32.html)

The following splatted `New-ShortCut` makes a `.url` shortcut to Sysinternals Process Explorer on your desktop with the microchip icon.

```ps
$ShortcutSplat = @{
    TargetPath   = '\\live.sysinternals.com\tools\procexp64.exe'
    ShortcutPath = "$env:USERPROFILE\Desktop\"
    Name         = 'Process Explorer'
    IconPath     = "$env:SystemRoot\System32\SHELL32.dll"
    IconIndex    = 12
}
New-ShortCut @ShortcutSplat
```
