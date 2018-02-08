Function Get-ComputerInfo {
    Param (
        [Parameter(Position=1, ValueFromPipelineByPropertyName=$True, ValueFromPipeline=$True)]
        [alias('Computer','Host','Hostname','Server','ServerName')]
        [String[]]$ComputerName = $env:computername,

        [pscredential]$Credential = $Null
    )
    BEGIN{
        $ErrorActionPreference = 'Stop'
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Begin Function"
    }
    PROCESS {
        Foreach ($Computer in $Computername){
            Write-Verbose "$FunctionName`: Attempting data retrieval via CIM for $computer"
            Try {
                If ($Credential){
                    $Computerinfo = start-job -scriptblock {Get-CIMInstance -Class Win32_OperatingSystem -ComputerName $args[0]} -argumentlist $computer -Credential $Credential | wait-job | receive-job
                    $Diskinfo = start-job -scriptblock {Get-CIMInstance -Class Win32_LogicalDisk -ComputerName $args[0]} -argumentlist $computer -Credential $Credential | wait-job | receive-job
                } else {
                    $Computerinfo = Get-CIMInstance -class Win32_OperatingSystem -ComputerName $computer
                    $Diskinfo = Get-CIMInstance -class Win32_LogicalDisk -ComputerName $computer
                    
                }
            } Catch {
                Write-verbose "$FunctionName`: Unable to retrieve data via WMI method.  Attempting WSMan connection."
                write-verbose "$FunctionName`: Error message $_"
            }
            If (($null -eq $ComputerInfo -or $null -eq $Diskinfo) -and ($computer -ne $env:computername)){
                Try {
                    If ($Credential){
                        $Session = New-PSSession -ComputerName $Computer -Credential $Credential
                    } else {
                        $Session = New-PSSession -ComputerName $Computer
                    }
                    $Computerinfo = Invoke-command -ScriptBlock {Get-CIMInstance -class Win32_OperatingSystem} -Session $Session
                    $Diskinfo = Invoke-command -ScriptBlock {Get-CIMInstance -class Win32_LogicalDisk} -Session $Session
                    Remove-PSSession $Session
                } Catch {
                    Remove-PSSession $Session
                    write-error "Unable to connect to $Computer. Error code`: $_"
                    return
                }
            }
            $output = New-object psobject -property @{
                'ComputerName' = $Computer
                'DiskInfo' = ''
                'OSName' = ''
                'Version' = ''
                'ServicePack' = ''
                'OSManufacturer' = ''
                'WindowsDirectory' = ''
                'Locale' = ''
                'AvailablePhysicalMemory' = ''
                'TotalVirtualMemory' = ''
                'AvailableVirtualMemory' = ''
            }
            If ($DiskInfo){
                $Disks=@()
                foreach ($disk in $diskinfo){
                    if ($Size -ne 0){$PercentFree = [uint64]$($disk.Freespace) / [uint64]$($disk.Size)}
                    $disks += new-object psobject -property @{
                        'Drive' = $disk.deviceid
                        'DriveType' = $disk.description
                        'Size' = $disk.Size
                        'FreeSpace' = $disk.FreeSpace
                        'Compressed' = $disk.compressed
                        'PercentFree' = $PercentFree
                    }
                $output.diskInfo = $disks
                }
            }
            If ($ComputerInfo){
                $output.OSName = $computerinfo.Name
                $output.Version = $computerinfo.Version
                $output.ServicePack = "$($ComputerInfo.ServicePackMajorVersion).$($computerinfo.ServicePackMinorVersion)"
                $output.OSManufacturer = $computerinfo.Manufacturer
                $output.WindowsDirectory = $computerinfo.WindowsDirectory
                $output.Locale = $computerinfo.Locale
                $output.AvailablePhysicalMemory = $computerinfo.FreePhysicalMemory
                $output.TotalVirtualMemory = $computerinfo.TotalVirtualMemorySize
                $output.AvailableVirtualMemory = $computerinfo.FreeVirtualMemory
            }
            return $output
        }
    }
}
