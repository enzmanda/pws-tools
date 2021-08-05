# set up paramters for reusability of the script
param (
    [Parameter(Mandatory = $true)]
    [String]$server, 
    [String]$saveLocation = ".\",
    [String]$name = "M",
    [Boolean]$Merge = $false # since merge is rather experimental, set the default value to false
)

# check and make sure that the drive is mounted, get the drive name used
if ( (Get-PSDrive).DisplayRoot -eq $server ) {
    $name = (Get-PSdrive | Where-Object { $_.DisplayRoot -eq $server }).Name
    Write-Host "Name has been set to $name"
}
else {
    New-PSDrive -Name  $name -Persist -PSProvider "FileSystem" -Root $server -Credential (Get-Credential) 
    Break
} # Mount PS drive here

# Create folder for CSV export unless it already exists
(Test-Path -Path "${saveLocation}tempCsv") ? (Write-Host "temp exists, skipping") : (New-Item -Path $saveLocation -Name "tempCsv" -ItemType "Directory")


# Get the directory and only a directory
$sourceDir = Get-ChildItem -Path "${name}:\"
# Loop through directories and create a new CSV file for each directory
forEach ($file in $sourceDir) {
    Write-Host "Exporting $file"
    Get-ChildItem -Path "$file" -Attributes D -Recurse | Select-Object -Property Parent,Name,LastWriteTime,Length | Export-Csv -Path "$saveLocation\tempCsv\$($file.Name).csv"
}

# merge all the CSV files into one big file
if ($Merge) {
    Get-ChildItem -Path "{$saveLocation}\tempCsv" -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | /
    Export-Csv -Path "${saveLocation}\FolderInformation${(Get-Date -Format yyyy-MM-dd-HHmm)}.csv" -NoTypeInformation -Append

    # Remove the temporary directory
    Remove-Item -Path "${saveLocation}\tempCsv"
} 
