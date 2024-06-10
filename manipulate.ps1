<#
SCript name: manipulate.ps1
Course: CIT361
Date: 6/4/24
Affidavit: We affirm this scrip is our original work.
Citations: We leveraged ideas and help from the following sources:
    -- ChatGPT
    
#>
function Get-MACVendor {
  param (
    [parameter(Mandatory=$false)]
    $MACAddress = $null,

    [parameter(Mandatory=$true)]
    [string]$DatabasePath 
  )

if (!(Test-Path -Path $DatabasePath)) {
    Write-Host "Error: The file path does not exist." -ForegroundColor red
} 
# else {
    # $file = Get-Item -Path $DatabasePath
# }
elseif ($null -ne $MACAddress) {
    (get-content $DatabasePath | findstr $MACAddress).split()[1]
}
else {
    if ($null -ne $macarr){
        clear-variable macarr
    }
        $macArr = @()
        get-netadapter | Select-Object MacAddress | ForEach-Object {$macArr += ($_.MacAddress.split('-')[0..2] -join ':')} 
#       $macArr | % { (gc $DatabasePath | findstr $_).split()[1]} 
        for ($i = 0; $i -lt $macArr.count -1 ; $i++) {
            try {
                Write-Host "$($macarr[$i]): " -NoNewLine
                (Get-Content $DatabasePath | findstr $macArr[$i]).split()[1]
            }
            catch {
                Write-Host 'address not found' -ForegroundColor red
            }
            
        }

}

}

