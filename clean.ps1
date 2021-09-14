# cleaning script for removal of files
[CmdletBinding()]
param (
    # The time range you would like to specify the deletion from
    [Parameter(Mandatory = $true)]
    [Int32]
    $TimeInDays,
    # Path to the root loaction of the removal
    [Parameter(Mandatory = $true)]
    [String]
    $Path,
    # Implement failsafe where files will be moved to a temporary location instead of removed right away, default value: False
    [Boolean]
    $failSafe = $false,
    # Temporary location, only required if you use the failSafe option
    [String]
    $tempLocation = ".\",
    # Enable or disable logging, default value: False
    [Boolean]
    $Logging = $false
)
# TODO: Add logging functionality that takes place if bool logging is set to true

$ExpiredFiles = @()

# remake this into a switch
If (Test-Path -Path $Path) {
    foreach ($file in (Get-ChildItem -Recurse -Path $Path) | Where-Object { 
            ([System.DateTimeOffset](((Get-Date).AddDays(-$TimeInDays)).ToUniversalTime())).ToUnixTimeSeconds() -gt ([System.DateTimeOffset]$_.CreationTimeUtc).ToUnixTimeSeconds() }) { 
        Write-Host "$($file.Name) created $($file.CreationTime) will be removed"
        $ExpiredFiles += $file.FullName
    }
}
else {
    Throw "Invalid Path"
}

# TODO: Issue #1
function removeFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Boolean]
        $FailSafe,
        [Parameter(Mandatory = $true)]
        [String]
        $tempLocation,
        [Parameter(Mandatory = $true)]
        [Object]
        $ExpiredFiles
    )

    # Fix object situation
    $Temp = "$($tempLocation)\Temp"
    If ($failSafe) {
        If (Test-Path -Path $Temp) {
            "Temp folder alraedy exists, skipping creation"
            # change this up to take attributes from the object
        }
        else {
            New-Item -Path $tempLocation -Name "Temp" -ItemType "directory" 
        }
        $ExpiredFiles.ForEach({
        Move-Item -Path $PSItem -Destination $Temp -Force
        })
        Write-Host "Do you wish to remove all files in the following directories? $(Get-ChildItem -Path $Temp -Attributes "Directory" | Select-Object $_.Name )"
        Remove-Item -Path $Temp -Recurse -Confirm
    }
    else {
        # change this up to take attributes from the object
        #  Write-Host "Removing contents of $File"
        #  Remove-Item -Path $File -Recurse
        $ExpiredFiles.ForEach({
                Remove-Item $PSItem -Force
            })
    }
}

removeFiles -FailSafe $failSafe -tempLocation $tempLocation -ExpiredFiles $ExpiredFiles
