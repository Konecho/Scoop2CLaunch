function FunCreateShortcuts{
    param($ShortcutsSet)
    $Shell = New-Object -ComObject WScript.Shell
    $i=0
    foreach ($Shortcut in $ShortcutsSet)
    {
        $ShortcutName = $Shortcut.Name
        $ShortcutFull = $Shortcut.FullName
        $ShortcutPath = $shortcut.DirectoryName
        $Temp = $Shell.CreateShortcut($Shortcut)
        $Target = $Temp.targetpath
        $Arguments = $Temp.Arguments
        $WorkingDirectory = $Temp.WorkingDirectory

        $ShortcutName=$ShortcutName.replace('.lnk','')
        $BtnNum=$i.toString($NULL).Padleft(3,'0')
        Add-Content -Path ".\CLaunch.ini" -Value "[Btn$BtnNum]"
        Add-Content -Path ".\CLaunch.ini" -Value "Position=$i"
        Add-Content -Path ".\CLaunch.ini" -Value "Type=00000001"
        Add-Content -Path ".\CLaunch.ini" -Value "Name=$ShortcutName"
        Add-Content -Path ".\CLaunch.ini" -Value "File=$Target"
        Add-Content -Path ".\CLaunch.ini" -Value "Parameter=$Arguments"
        Add-Content -Path ".\CLaunch.ini" -Value "Directory=$WorkingDirectory"
        Add-Content -Path ".\CLaunch.ini" -Value "WindowStat=1"
        Add-Content -Path ".\CLaunch.ini" -Value "Flag=00000020"
        Add-Content -Path ".\CLaunch.ini" -Value "Tip=$ShortcutName"
        Add-Content -Path ".\CLaunch.ini" -Value "IconIndex=0"
        Add-Content -Path ".\CLaunch.ini" -Value "IconFile="
        Add-Content -Path ".\CLaunch.ini" -Value "Keyboard=0000"
        Add-Content -Path ".\CLaunch.ini" -Value ""
        Write-Output "add $ShortcutName"
        $i=$i+1

    }

[Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null
}
function FunCreatePage{
    param($ShortcutsSet,$PageName)
    $ShortcutsCount = $ShortcutsSet.Count

    Write-Output "$ShortcutsCount Shortcuts will be add"

    $regex = '\[Pages\]\r\nCount=(?<PageCount>[0-9]+)'

    (Get-Content -Raw .\CLaunch.ini) -match $regex | Out-Null

    $PageCountPlusOne = [int16]$Matches.PageCount + 1
    (Get-Content -Raw .\CLaunch.ini) -replace $regex, "[Pages]`r`nCount=$PageCountPlusOne" | Set-Content .\CLaunch.ini

    $NewPageNum = $Matches.PageCount.PadLeft(3, '0')
    Add-Content -Path ".\CLaunch.ini" -Value "[Page$NewPageNum]"

    Add-Content -Path ".\CLaunch.ini" -Value "Name=$PageName"

    Add-Content -Path ".\CLaunch.ini" -Value "Count=$ShortcutsCount"

    Add-Content -Path ".\CLaunch.ini" -Value 'ScrollMode1=0'
    Add-Content -Path ".\CLaunch.ini" -Value 'ScrollMode2=0'
    Add-Content -Path ".\CLaunch.ini" -Value 'Flag=00000000'
    Add-Content -Path ".\CLaunch.ini" -Value ""

}
function FunCreateSubMenu{
    param($ShortcutsSet,$SubMenuName,$SubMenuPage,$SubMenuButton)
    $ShortcutsCount = $ShortcutsSet.Count

    Write-Output "$ShortcutsCount Shortcuts will be add"

    $regex = '\[SubMenus\]\r\nCount=(?<SubMenusCount>[0-9]+)'

    (Get-Content -Raw .\CLaunch.ini) -match $regex | Out-Null

    $SubMenusCountPlusOne = [int16]$Matches.SubMenusCount + 1
    (Get-Content -Raw .\CLaunch.ini) -replace $regex, "[SubMenus]`r`nCount=$SubMenusCountPlusOne" | Set-Content .\CLaunch.ini

    $NewSubMenuNum = $Matches.SubMenusCount.PadLeft(3, '0')
    Add-Content -Path ".\CLaunch.ini" -Value "[Page$NewSubMenuNum]"

    Add-Content -Path ".\CLaunch.ini" -Value "Page=$SubMenuPage"
    
    Add-Content -Path ".\CLaunch.ini" -Value "Button=$SubMenuButton"

    Add-Content -Path ".\CLaunch.ini" -Value "Count=$ShortcutsCount"


}
function FunCreateMultiPage{
    param($ShortcutsSet,$PageName)
    $m = 4*20
    $a=$ShortcutsSet
    $z = for ($i = 0; $i -lt $a.length; $i += $m) { ,$a[$i..($i+$m-1)] }
    $zc = $z.count

    Write-Output "ShortcutsSet $PageName was devided into $zc parts"

    for ($j = 0; $j -lt $zc; $j += 1) {
        FunCreatePage -ShortcutsSet $z[$j] -PageName "$PageName ($j)"
        FunCreateShortcuts -ShortcutsSet $z[$j]
    }
}
Write-Output "script started"

Copy-Item .\CLaunch.ini -Destination .\OriginCLaunch.ini

# When using the -Include parameter, if you don't include an asterisk in the path
# the command returns no output.


###Scoop Apps
$Shortcuts = Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\*" -Include *.lnk

FunCreatePage -ShortcutsSet $Shortcuts -PageName "Scoop Apps"
FunCreateShortcuts -ShortcutsSet $Shortcuts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###SysInternals
#$Shortcuts = Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\SysInternals\*" -Include *.lnk

#FunCreatePage -ShortcutsSet $Shortcuts -PageName "SysInternals"
#FunCreateShortcuts -ShortcutsSet $Shortcuts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###WinPython
$Shortcuts = Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\WinPython\*" -Include *.lnk

FunCreateSubMenu -ShortcutsSet $Shortcuts -PageName "WinPython" -SubMenuPage "0000" -SubMenuButton "8"
FunCreateShortcuts -ShortcutsSet $Shortcuts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###NirSoft
#$Shortcuts = Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\NirSoft\*" -Include *.lnk

#FunCreateMultiPage -ShortcutsSet $Shortcuts -PageName "NirSoft"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###
Write-Output "script finished"