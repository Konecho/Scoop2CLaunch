function Get-StartMenuShortcuts{
    $Shortcuts = Get-ChildItem -Recurse "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps" -Include *.lnk
    $Shell = New-Object -ComObject WScript.Shell
    $i=0
    foreach ($Shortcut in $Shortcuts)
    {
        
        $ShortcutName = $Shortcut.Name;
        $ShortcutFull = $Shortcut.FullName;
        $ShortcutPath = $shortcut.DirectoryName
        $Target = $Shell.CreateShortcut($Shortcut).targetpath
        $arguments = $Shell.CreateShortcut($Shortcut).arguments 
        $workingDirectory = $Shell.CreateShortcut($Shortcut).workingDirectory 
       
        $name=$Shortcut.Name.replace('.lnk','')
        $ooi=$i.toString($NULL).Padleft(3,'0')
        Add-Content -Path ".\CLaunch.ini" -Value "[Btn$ooi]"
        Add-Content -Path ".\CLaunch.ini" -Value "Position=$i"
        Add-Content -Path ".\CLaunch.ini" -Value "Type=00000001"
        Add-Content -Path ".\CLaunch.ini" -Value "Name=$name"
        Add-Content -Path ".\CLaunch.ini" -Value "File=$Target"
        Add-Content -Path ".\CLaunch.ini" -Value "Parameter=$arguments"
        Add-Content -Path ".\CLaunch.ini" -Value "Directory=$workingDirectory"
        Add-Content -Path ".\CLaunch.ini" -Value "WindowStat=1"
        Add-Content -Path ".\CLaunch.ini" -Value "Flag=00000020"
        Add-Content -Path ".\CLaunch.ini" -Value "Tip=$name"
        Add-Content -Path ".\CLaunch.ini" -Value "IconIndex=0"
        Add-Content -Path ".\CLaunch.ini" -Value "IconFile="
        Add-Content -Path ".\CLaunch.ini" -Value "Keyboard=0000"
        $i=$i+1
        
    }

[Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null
}


$regex = '\[Pages\]\r\nCount=(?<count>[0-9]+)'

#$file = Get-Content ".\CLaunch.ini"
(Get-Content -Raw .\CLaunch.ini) -match $regex

$plusone= [int16]$Matches.count+1
(Get-Content -Raw .\CLaunch.ini) -replace $regex,"[Pages]`r`nCount=$plusone" | Set-Content .\CLaunch.ini

$newpage=$Matches.count.PadLeft(3,'0')
Add-Content -Path ".\CLaunch.ini" -Value "[Page$newpage]"

Add-Content -Path ".\CLaunch.ini" -Value "Name=Scoop Apps"

$count=$Shortcuts.Count
Add-Content -Path ".\CLaunch.ini" -Value "Count=$count"

Add-Content -Path ".\CLaunch.ini" -Value 'ScrollMode1=0'
Add-Content -Path ".\CLaunch.ini" -Value 'ScrollMode2=0'
Add-Content -Path ".\CLaunch.ini" -Value 'Flag=00000000'



Get-StartMenuShortcuts
