function Get-CertutilObjectList($certutilOutput){

    <#
    .SYNOPSIS
    Converts any certutil.exe output into a PowerShell object list/array

    .DESCRIPTION
    Converts any certutil.exe output into an object list/array to make it available for further use with PowerShell

    .PARAMETER certutilOutput
    The unchanged certutil.exe output

    .NOTES
    Version:        1.2
    Author:         Tobias Undeutsch
    URL:            https://www.pwsh.ch
    Date:           22.03.2018

    .EXAMPLE
    Get-CertutilObjectList(Invoke-Expression "$($env:SystemRoot)\system32\certutil.exe")

    .EXAMPLE
    Get-CertutilObjectList(Invoke-Expression "$($env:SystemRoot)\system32\certutil.exe -view -restrict disposition==20")

    .EXAMPLE
    Get-CertutilObjectList(Invoke-Expression "$($env:SystemRoot)\system32\certutil.exe -view Revoked")

    .EXAMPLE
    Get-CertutilObjectList(Invoke-Expression "$($env:SystemRoot)\system32\certutil.exe -CATemplates")

    #>

    $certutilObjectList = New-Object System.Collections.ArrayList

    # Step 1 - Parse certutil basic attributes
    $currentKey = $null
    $currentValue = $null
    $endReached = $false
    $certutilOutput -split [environment]::NewLine | foreach {

        # Run until the end of the usable stdout is reached
        if($endReached -eq $false) {

            switch -regex ($_){

                # End of usable stdout reached
                '^(Maximum Row Index|CertUtil):' {
                    $endReached = $true
                }

                # New object detected
                '(Entry|Row) \d+:(.*)' {

                    # Add the current object to the output list, if there is one and add the last key / value pair if necessary
                    if($currentObject){ 
                        if($currentKey -and $currentValue){
                            $currentObject | Add-Member -MemberType NoteProperty -Name $currentKey -Value $currentValue -Force 
                        }
                        $certutilObjectList.Add($currentObject) | Out-Null
                    }
            
                    # Create new object
                    $currentObject = New-Object psobject
                    $currentKey = $null
                    $currentValue = $null
                }

                # Add key / value pair to the current object if there is one
                '(^\s{2})(?<key>\w+[\w\s\|/]+):\s*(?<value>.*)' {
                    if($currentObject){ 

                        # Add the "old" multiline value to the object, if there is one
                        if($currentKey -and $currentValue){
                            $currentObject | Add-Member -MemberType NoteProperty -Name $currentKey -Value $currentValue -Force 
                        }

                        # Register the current "new" key / value pair 
                        $currentKey = $matches.key.Trim()
                        $currentValue = $matches.value
                        $currentObject | Add-Member -MemberType NoteProperty -Name $currentKey -Value $currentValue -Force 
                    }
                }

                # Empty line, do noting
                '^$' { }

                # Default behaviour for not fetched rows up to now (usually multiline values)
                default {
                    if($currentObject -and $currentKey){ 
                    
                        if(!$currentValue){
                            $currentValue += $_
                        }
                        else {
                            $currentValue += "`n$_"
                        }
                    }

                }
            } # end switch
        } # end if
    } # end foreach

    # Add last object to objectList, if there is one and add the last key / value pair if necessary
    if($currentKey -and $currentValue){
        $currentObject | Add-Member -MemberType NoteProperty -Name $currentKey -Value $currentValue -Force 
    }
    if($currentObject){
        $certutilObjectList.Add($currentObject) | Out-Null
    }

    # Step 2 - Parse Certificate Extensions
    $certutilObjectList = $certutilObjectList | foreach {

        # Only work with the Certificate Extensions
        if($_."Certificate Extensions"){

            # Build Certificate Extensions object list
            $counter = -1
            $out = Select-String -Pattern '(\s+([\d|.]+):.*\n)\s+(.*)' -InputObject $_."Certificate Extensions" -AllMatches
            $certExtensionObjectList = $_."Certificate Extensions" -split '\s+[\d|.]+:.*\n\s+.*' | foreach {
                if($counter -ge 0){
                    $obj = New-Object psobject
                    $obj | Add-Member -MemberType NoteProperty -Name "ID" -Value $out.Matches[$counter].Groups[2].Value
                    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $out.Matches[$counter].Groups[3].Value
                    $obj | Add-Member -MemberType NoteProperty -Name "Data" -Value "$(($_ -split [environment]::NewLine | foreach { $_ -replace '^\s{9}','' } ) -join [environment]::NewLine )"
                    $obj
                }
                $counter++
            }

            # Write the Certificate Extensions object list back into the Certificate Extensions Attribute of the certutil object
            $_ | Add-Member -MemberType NoteProperty -Name "Certificate Extensions" -Value $certExtensionObjectList -Force 
        }

        # Write the object back into the array/list
        $_
    }

    # Return array/list with certutil objects
    return $certutilObjectList
}


# Examples
$certutil = "$($env:SystemRoot)\system32\certutil.exe"
$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil")$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil -view -restrict 'Certificate Template=my.template.id'")
$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil -view -restrict 'disposition=20,notbefore>01/01/2018'")