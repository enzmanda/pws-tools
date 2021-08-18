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

$ExpiredFiles = New-Object PSObject -Property @{}

# remake this into a switch
# instead of just writing to host, create an object that stores the files to be removed due to the failsafe
# TODO: change folder to file
If (Test-Path -Path $Path) {
    foreach ($folder in (Get-ChildItem -Path $Path -Attributes Directory) | Where-Object { 
            ([System.DateTimeOffset](((Get-Date).AddDays(-$TimeInDays)).ToUniversalTime())).ToUnixTimeSeconds() -gt ([System.DateTimeOffset]$_.CreationTimeUtc).ToUnixTimeSeconds() }) { 
        Write-Host "$($folder.Name) created $($folder.CreationTime) will be removed"
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
            Move-Item -Path $folder -Destination $Temp -Force
        }
        else {
            New-Item -Path $tempLocation -Name "Temp" -ItemType "directory" 
        }
        Write-Host "Do you wish to remove all files in the following directories? $(Get-ChildItem -Path $Temp -Attributes "Directory" | Select-Object $_.Name )"
        Remove-Item -Path $Temp -Recurse -Confirm
    }
    else {
            # change this up to take attributes from the object
        Write-Host "Removing contents of $File"
        Remove-Item -Path $File -Recurse
    }
}