Param (
    [Parameter(Mandatory=$true)]
    [String]$PrinterName,
    [Parameter(Mandatory=$true)]
    [String]$PrinterIP,
    [Parameter(Mandatory=$true)]
    [String]$DriverName,
    [String]$InfDir
)

# Checking drivers
Switch ($InfDir, $DriverName) {
    # check if inf file is valid
    { $InfDir -isnot $null } {
        if (Test-Path $InfDir) { 
            "Installing provided driver from: ${InfDir}"  
            (Get-ChildItem $InfDir -Recurse -Filter "*.inf").foreach( {
                    pnputil.exe /add-driver $_.FullName /install 
                })
            break 
        }
        else { 
            "No valid inf-file provided, no driver will be installed" 
        }
        # check driver name to be legit
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

# Verify network connection
(Test-Connection -TargetName $PrinterIP -IPv4) ? ("Connection to printer can be established") : ( Throw "Cannot reach printer, check your network connection")

#Install the Driver:
Add-PrinterDriver -Name $DriverName
#Create the local Printer Port
Add-PrinterPort -Name "TCP:${PrinterIP}" -PrinterHostAddress $PrinterIP
#And then add the printer, using the Port, Driver and Printer name you've chosen
Add-Printer -Name $PrinterName -PortName "TCP:${PrinterIP}" -DriverName $DriverName -Shared:$false

