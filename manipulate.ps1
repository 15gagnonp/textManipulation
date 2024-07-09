<#
SCript name: manipulate.ps1
Course: CYBER360 
Date: 6/4/24
Authors: Preston Gagnon, Coleman Loewen
Affidavit: We affirm this scrip is our original work.
Citations: We leveraged ideas and help from the following sources:
    -- ChatGPT
    -- StackOverflow
    
#>
function Get-MACVendor {
  param (
    [parameter(Mandatory=$false)]
    $MACAddress,

    [parameter(Mandatory=$true)]
    [string]$DatabasePath 
  )
# code is resused
if (!(Test-Path -Path $DatabasePath)) {
    Write-Host "Error: The file path does not exist." -ForegroundColor red
} 
elseif ($null -ne $MACAddress) {
    $MACAddress = $MACAddress.split('-')[0..2] -join ':'
    $MACAddress = $MACAddress.substring(0,8)
    $data = (get-content $DatabasePath | findstr $MACAddress.ToUpper())
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
    if ($null -ne $macarr){
        clear-variable macarr
    }
        $macArr = @()
        get-netadapter | Select-Object MacAddress | ForEach-Object {$macArr += ($_.MacAddress.split('-')[0..2] -join ':')} 
        #$macArr | % { (gc $DatabasePath | findstr $_).split()[1]} 
        for ($i = 0; $i -lt $macArr.count -1 ; $i++) {
            try {
                Write-Host "$($macarr[$i]): " -NoNewLine
                (Get-Content $DatabasePath | findstr $macArr[$i]).split(0x09)[1]
            }
            catch {
                Write-Host 'address not found' -ForegroundColor red
            }
            
        }

}

}
function Format-Songs {
    param (
        [parameter(Mandatory=$false)]
        $OutPath = $null,

        [parameter(Mandatory=$true)]
        [string]$DatabasePath = $null 
    )
    ## code is resused
    if (!(Test-Path -Path $DatabasePath)) {
        Write-Host "Error: The Database path does not exist." -ForegroundColor red
    } 
    else {
        $content = Get-Content $DatabasePath -Raw
        $records = $content -split "`n" | ForEach-Object {
            if ($_.Trim() -ne "") {
                $parts = $_ -split "`t"
                [PSCustomObject]@{
                    Song    = $parts[0]
                    Album   = $parts[1]
                    Year    = $parts[2]
                    Notes   = $parts[3]
                }
            }
        }
    }
    if($null -eq $OutPath) {
        $groupedData = $records | Group-Object -Property Album, Year
        foreach ($group in $groupedData) {
            $album = $group.Name.Split(',')[0].Trim()
            $year = $group.Name.Split(',')[1].Trim()
            $songs = $group.Group | Sort-Object -Property song
            
            Write-Output "$album ($year)"
            
            foreach($song in $songs) {
                Write-Output "  $($Song.song)"
            }

        }
    }
    elseif (!(Test-Path -Path $OutPath)) {
        Write-Host "Error: The Outfile path does not exist." -ForegroundColor red
    }
    else {
        $groupedData = $records | Group-Object -Property Album, Year
        foreach ($group in $groupedData) {
            $album = $group.Name.Split(',')[0].Trim()
            $year = $group.Name.Split(',')[1].Trim()
            $songs = $group.Group | Sort-Object -Property song
            
            Write-Output "$album ($year)" >> $OutPath
            
            foreach($song in $songs) {
                Write-Output "  $($Song.song)" >> $OutPath
            }

        }## end reused code
    }
}



