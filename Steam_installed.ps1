$colObject = @()
$sRegKeys = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -Name "SteamPath")
#$path = "D:\Program Files (x86)\Steam\SteamApps"
$path = "$(($sRegKeys.SteamPath).Replace("/","\"))\steamapps"
$files = Get-ChildItem -name $path -Filter "*.acf"

foreach ($file in $files) {
    $json = Get-Content -Raw -Path $path\$file
    $appid = $json | Select-String -Pattern '.*"appid"\t\t"(.*)"'
    $appid = $appid.Matches.Groups[1]
    $name = $json | Select-String -Pattern '.*"name"\t\t"(.*)"'
    $name = $name.Matches.Groups[1]
    $ourObject = New-Object System.Object
    $ourObject | Add-Member -MemberType NoteProperty -Name File -Value "$($path)\$($file)"
    $ourObject | Add-Member -MemberType NoteProperty -Name AppID -Value $appid
    $ourObject | Add-Member -MemberType NoteProperty -Name Name -Value $name
    $colObject += $ourObject
}

$colObject | Export-csv $PSScriptRoot\Steam_Game_List.csv -notypeinformation