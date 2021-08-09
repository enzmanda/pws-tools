# cleaning script for removal of files

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [Int32]
    $TimeInDays,
    [Parameter(Mandatory = $true)]
    [String]
    $Path,
    [String]
    $tempLocation = ".\",
    [Boolean]
    $failSafe = $false
)

$Temp = "$($tempLocation)\Temp"

If (Test-Path -Path $Temp) {
    "Temp folder alraedy exists, skipping creation"
}
else {
    New-Item -Path $tempLocation -Name "Temp" -ItemType "directory" 
}

If (Test-Path -Path $Path) {
    foreach ($folder in (Get-ChildItem -Path $Path -Attributes Directory) | Where-Object { 
            ([System.DateTimeOffset](((Get-Date).AddDays(-$TimeInDays)).ToUniversalTime())).ToUnixTimeSeconds() -gt ([System.DateTimeOffset]$_.CreationTimeUtc).ToUnixTimeSeconds() }) { 
        Write-Host "$($folder.Name) created $($folder.CreationTime) will be removed"
        Move-Item -Path $folder -Destination $Temp -Force
    }
}
else {
    Throw "Invalid Path"
}

If ($failSafe) {
    Write-Host "Do you wish to remove all files in the following directories? $(Get-ChildItem -Path $Temp -Attributes "Directory" | Select-Object $_.Name )"
    Remove-Item -Path $Temp -Recurse -Confirm
} else {
    Write-Host "Removing contents of $Temp"
    Remove-Item -Path $Temp -Recurse
}