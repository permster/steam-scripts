$colObject = @()
$steam_library_folders = @()
$sRegKeys = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -Name "SteamPath")
#$path = "D:\Program Files (x86)\Steam\SteamApps"
$steam_path = "$(($sRegKeys.SteamPath).Replace("/","\"))\steamapps"

$library_file = Get-Content -Raw -Path "$steam_path\libraryfolders.vdf"
$library_folders =  $library_file | Select-String -Pattern '(?m).*"path"\t\t"(.*)"' -AllMatches
$library_folders.Matches | ForEach-Object { $steam_library_folders += "$(($_.Groups[1].value).Replace("\\", "\"))\steamapps" }

foreach ($library_folder in $steam_library_folders) {
    $files = Get-ChildItem -name $library_folder -Filter "*.acf"

    foreach ($file in $files) {
        $json = Get-Content -Raw -Path $library_folder\$file
        $appid = $json | Select-String -Pattern '.*"appid"\t\t"(.*)"'
        $appid = $appid.Matches.Groups[1]
        $name = $json | Select-String -Pattern '.*"name"\t\t"(.*)"'
        $name = $name.Matches.Groups[1]
        $ourObject = New-Object System.Object
        $ourObject | Add-Member -MemberType NoteProperty -Name File -Value "$($library_folder)\$($file)"
        $ourObject | Add-Member -MemberType NoteProperty -Name AppID -Value $appid
        $ourObject | Add-Member -MemberType NoteProperty -Name Name -Value $name
        $colObject += $ourObject
    }
}

$colObject | Export-csv $PSScriptRoot\Steam_Game_List.csv -notypeinformation