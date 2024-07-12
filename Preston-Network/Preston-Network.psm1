<#
Program Name: Preston-Network.psm1
Course: CYBER360 
Date: 7/11/24
Authors: Preston Gagnon
Affidavit: We affirm this scrip is our original work.
Citations: We leveraged ideas and help from the following sources:
    -- ChatGPT
    -- StackOverflow
    
#>
Class MAC {
    [string]$Address
    [string]$Vendor

    MAC($Address) {
        $Address.split('-') -join ':'
       $This.Address = $Address
    }

    [string] MACVendorID () {
        return ($This.Address.split(':')[0..2] -join ':').ToUpper()
    }

    Static [String] MACVendorID ([string]$Address) {
        return ($Address.split(':')[0..2] -join ':').ToUpper()
    }

}


function Get-MACVendor {
  param (
    [parameter(Mandatory=$false)]
    $MACAddress,

    [parameter(Mandatory=$false)]
    [string]$DatabasePath 
  )
# code is resused
if (!(Test-Path -Path $DatabasePath)) {
    $dataFilePath = Join-Path -Path $PSScriptRoot -ChildPath ".\MACDatabase.txt"
    Write-Host "Using built-in MAC Database" -ForegroundColor red
    $DatabasePath = $dataFilePath
    
} 
if ($null -ne $MACAddress) {
    ## $MACAddress = $MACAddress.split('-')[0..2] -join ':'
    ## $MACAddress = $MACAddress.substring(0,8)
    $Address = [MAC]::new($MACAddress)
    $Address.address = $MACAddress
    $data = (get-content $DatabasePath | findstr $Address.MACVendorID())
    if($null -eq $data)
    {
        Write-Host "Error: Mac address not found" -ForegroundColor red
    }
    else {
        $data.split()[1]
    }
}
# code is resused
else {
    ## If no mac-address is supplied use get-netadapter to find mac address 
    ## of local device and find vendors of those.

    ## I left this one not using the MacAddress data type because it didnt make a lot of sense 
    ## to use it based on the way we designed the program.
    if ($null -ne $macarr){
        clear-variable macarr
    }
        $macArr = @()
        get-netadapter | Select-Object MacAddress | ForEach-Object {$macArr += ($_.MacAddress.split('-')[0..2] -join ':')} 
        $database = Get-Content $DatabasePath
        for ($i = 0; $i -lt $macArr.count -1; $i++) {
            try {
                Write-Host "$($macarr[$i]): " -NoNewLine
                ($DataBase | findstr $macArr[$i]).split(0x09)[1]
            }
            catch {
                Write-Host 'address not found' -ForegroundColor red
            }
            
        }

}

function Get-IPNetwork {
    <#
    .SYNOPSIS
    Given an IP address and a subnet mask, return its subnet ID
    .DESCRIPTION
    Given an IP address and a subnet mask, return the subnet ID
    of the network on which that address resides.
    .PARAMETER IPAddr
    The IPvr address as a "dotted-quad" string
    .PARAMETER SubnetMask
    The subnet mask as a "dotted-quad" string
    .EXAMPLE
    Get-IPNetwork -IPAddr "192.168.3.4" -SubnetMask "255.255.255.0"
    returns "192.168.3.0"
    #>
    param($IPAddr, $SubnetMask)
    $i32_Addr = ([IPAddress]$IPAddr).Address
    $i32_Mask= ([IPAddress]$SubnetMask).Address
    $i32_SubnetID = $i32_Addr -band $i32_Mask
    $SubnetID = [IPAddress]$i32_SubnetId
    return $SubnetID.IPAddressToString
}

function Test-IPNetwork {
    <#
    .SYNOPSIS
    Given two IP addresses and a subnetmask, return true or false
    .DESCRIPTION
    If bother IP addresses are in the same network return true, if both
    IP addresses are in different networks return false.
    .PARAMETER IPAddr1
    The IPv4 address as a "dotted-quad" string
    .PARAMETER IPAddr2
    The IPv4 address as a "dotted-quad" string
    .PARAMETER SubnetMask
    The subnet mask as a "dotted-quad" string
    .EXAMPLE
    Test-IPNetwork -IPAddr1 "10.10.49.121" -IPAddr1 "10.10.55.254" -SubnetMask "255.255.248.0"
    returns False
    #> 
    param ($IPAddr1, $IPAddr2, $SubnetMask)
    $SubnetId1 = Get-IPNetwork -IPAddr $IPAddr1 -SubnetMask $SubnetMask
    $SubnetId2 = Get-IpNetwork -IPAddr $IPAddr2 -SubnetMask $SubnetMask
    if ($SubnetId1 -eq $subnetId2) {
        return $true
    }
    else {
        return $false
    }
}

}



