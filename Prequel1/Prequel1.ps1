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
                    $Monitorinfo = Start-job -scriptblock {Get-CIMInstance -Namespace root\wmi -Class wmiMonitorID -ComputerName $args[0]} -argumentlist $computer -Credential $Credential | wait-job | receive-job
                    $Computerinfo = start-job -scriptblock {Get-CIMInstance -Class Win32_ComputerSystem -ComputerName $args[0]} -argumentlist $computer -Credential $Credential | wait-job | receive-job
                    $BIOSinfo = start-job -scriptblock {Get-CIMInstance -Class Win32_BIOS -ComputerName $args[0]} -argumentlist $computer -Credential $Credential | wait-job | receive-job
                } else {
                    $Monitorinfo = Get-CIMInstance -Namespace root\wmi -Class wmiMonitorID -ComputerName $computer
                    $Computerinfo = Get-CIMInstance -class Win32_ComputerSystem -ComputerName $computer
                    $BIOSinfo = Get-CIMInstance -class Win32_BIOS -ComputerName $computer
                    
                }
            } Catch {
                Write-verbose "$FunctionName`: Unable to retrieve data via WMI method.  Attempting WSMan connection."
                write-verbose "$FunctionName`: Error message $_"
            }
            If (($null -eq $MonitorInfo -or $null -eq $computerinfo -or $Null -eq $BIOSinfo) -and ($computer -ne $env:computername)){
                Try {
                    If ($Credential){
                        $Session = New-PSSession -ComputerName $Computer -Credential $Credential
                    } else {
                        $Session = New-PSSession -ComputerName $Computer
                    }
                    $Computerinfo = Invoke-command -ScriptBlock {Get-CIMInstance -class Win32_ComputerSystem} -Session $Session
                    $BIOSinfo = Invoke-command -ScriptBlock {Get-CIMInstance -class Win32_BIOS} -Session $Session
                    $Monitorinfo = Invoke-command -ScriptBlock {Get-CIMInstance -namespace root\wmi -class wmiMonitorID} -Session $Session -ErrorAction SilentlyContinue
                    Remove-PSSession $Session
                } Catch {
                    Remove-PSSession $Session
                    write-error "Unable to connect to $Computer. Error code`: $_"
                    return
                }
            }
            $output = New-object psobject -property @{
                'ComputerName' = $Computer
                'MonitorInfo' = ''
                'ComputerType' = ''
                'ComputerSerial' = ''
            }
            If ($MonitorInfo){
                $monitors=@()
                foreach ($monitor in $monitorinfo){
                    $monitors += new-object psobject -property @{
                        'MonitorSerial' = [System.Text.Encoding]::Default.GetString($Monitor.SerialNumberID)
                        'MonitorType' = [System.Text.Encoding]::Default.GetString($monitor.UserFriendlyName)
                    }
                $output.MonitorInfo = $monitors
                }
            }
            If ($ComputerInfo){
                $output.ComputerType = $computerinfo.model
            }
            If ($Biosinfo){
                $output.ComputerSerial = $BIOSinfo.serialnumber
            }
            return $output
        }
    }
}
