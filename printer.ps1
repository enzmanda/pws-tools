Param (
    [Parameter(Mandatory = $true)]
    [String]$PrinterName,
    [Parameter(Mandatory = $true)]
    [String]$PrinterAddress,
    [String]$UserName,
    [Parameter(Mandatory = $true)]
    [String]$DriverName,
    [String]$InfDir
)

# Checking drivers
Switch ($InfDir, $DriverName) {
    # check if inf file is valid
    { $InfDir -isnot $null } {
        if (Test-Path $InfDir) {
            # add an and here to make sure there is an .inf file here somewhere
            "Installing provided driver from: ${InfDir}"  
            (Get-ChildItem $InfDir -Recurse -Filter "*.inf").foreach( {
                    pnputil.exe /add-driver $_.FullName /install 
                })
            break 
        }
        else { 
            "No valid inf-file provided, no driver will be installed" 
        }
        # check driver name to be legit and that the driver in question is installed
    } { $DriverName -isnot $null } { 
        if ($null -ne (Get-PrinterDriver -Name $DriverName)) {
            Write-Host "Required driver ${$DriverName} is installed"
            break 
        }
        else { 
            Throw "No valid driver provided, exiting" 
        }
    } Default {
        Throw "No valid driver or inf file provided, exiting"
    }
}


# Verify network connection and add printer
if (Test-Connection -TargetName $PrinterIP -IPv4) { 
    "Connection to printer can be established" 
    #Install the Driver:
    Add-PrinterDriver -Name $DriverName
    #Create the local Printer Port
    if ($null -ne $UserName) {
        $ConnectionName = "$($PrinterAddress)/$($UserName)"
    } 
    else {
        $ConnectionName = $PrinterAddress
    }
    Add-Printer -Name $PrinterName -ConnectionName $ConnectionName -DriverName $DriverName -Shared:$false
}
else { 
    Throw "Cannot reach printer, check your network connection" 
}


