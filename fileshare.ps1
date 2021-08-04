# set up paramters for reusability of the script
param (
    [String]$server = "\\hkgfs01.kregav.net\Tokyo$", # Should result in this being a default value unless other paramtere is provided 
    [String]$saveLocation = ".\",
    [String]$name = "M",
    [Boolean]$Merge = $false # since merge is rather experimental, set the default value to false
)

# check and make sure that the drive is mounted, get the drive name used
switch ((Get-PSDrive).Root) {
    $server {
        $name = (Get-PSdrive | Where-Object {$_.Root -like "*${server}*"}).Name
        Break
    }
    default {
        New-PSDrive -Name  $name -Persist -PSProvider "FileSystem" -Root $server -Credential (Get-Credential) 
        Break
    } # Mount PS drive here
}

# Create folder for CSV export unless it already exists
(Test-Path -Path "${saveLocation}tempCsv") ? (Write-Host "temp exists, skipping") : (New-Item -Path $saveLocation -Name "tempCsv" -ItemType "Directory")


# Get the directory
$sourceDir = Get-ChildItem -Path "${name}:\" -Filter "Directory"
# Loop through directories and create a new CSV file for each directory
forEach ($file in $sourceDir) {
    $filename = $file.Name
    Write-Host "Exporting ${filename}"
    # Create a new Object entry for each folder and list all the names under that object, warning, these files might be huge depending on how big the folders are
    Get-ChildItem -Path "$file" -Recurse -Filter "Directory" | Select-Object -Property Directory,Name,LastWrite,Length | Export-Csv -Path "$saveLocation\tempCsv\${filename}.csv"
}

# merge all the CSV files into one big file
if ($Merge) {
    Get-ChildItem -Path "{$saveLocation}\tempCsv" -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | /
    Export-Csv -Path "${saveLocation}\FolderInformation${(Get-Date -Format yyyy-MM-dd-HHmm)}.csv" -NoTypeInformation -Append

    # Remove the temporary directory
    Remove-Item -Path "${saveLocation}\tempCsv"
} 
