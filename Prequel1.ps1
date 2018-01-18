Function Get-ComputerInfo {
    Param (
        [Parameter(Position=1,Mandatory=$True, ValueFromPipelineByPropertyName=$True, ValueFromPipeline=$True)]
        [alias('Computer','Host','Hostname','Server','ServerName')]
        [String[]]$ComputerName,

        [pscredential]$Credential = $Null
    )
    BEGIN{
        $ErrorActionPreference = 'Stop'
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Begin Function"
    }
    PROCESS {
        Foreach ($Computer in $Computername){
            Write-Verbose "$FunctionName`: Attempting data retrieval via WMI"
            Try {
                If ($Credential){
                    $Monitorinfo = Get-WMIObject -Namespace root\wmi -Class wmiMonitorID -Credential $Credential
                    $Computerinfo = Get-WMIObject -Class Win32_ComputerSystem -Credential $Credential
                } else {
                    $Monitorinfo = Get-WMIObject -Namespace root\wmi -Class wmiMonitorID
                    $Computerinfo = Get-WMIObject -Class Win32_ComputerSystem
                    
                }
                If (! $Monitorinfo){Throw "No monitor data available"}
                If (! $Computerinfo){Throw "No computer data available"}
            } Catch {
                Write-verbose "$FunctionName`: Unable to retrieve data via WMI method.  Attempting WSMan connection."
                write-verbose "$FunctionName`: Error message $_"
            }
            Try {
                If ($Credential){
                    $Session = New-PSSession -ComputerName $Computer -Credential $Credential
                } else {
                    $Session = New-PSSession -ComputerName $Computer
                }

                $Monitorinfo = Invoke-command -ScriptBlock {Get-WMIObject -namespace root\wmi -class wmiMonitorID} -Session $Session
                $Computerinfo = Invoke-command -ScriptBlock {Get-WMIObject -class Win32_ComputerSystem} -Session $Session
            } Catch {
                write-error "Unable to connect to $Computer"
                Remove-PSSession $Session
                return
            }
            $monitors=@()
            If ($Monitor -and $Computer){
                foreach ($monitor in $monitorinfo){
                    $monitors += new-object psobject -properties @{
                        'MonitorSerial' = ($Monitor.SerialNumberID -ne 0 | %{[char]$_}) -join ""
                        'MonitorType' = ($monitor.UserFriendlyName -ne 0 | %{[char]$_}) -join ""
                    }
                }
                $output = new-object psobject -properties @{
                    'ComputerName' = $Computer
                    'ComputerType' = $Computerinfo.model
                    'ComputerSerial' = $computerinfo.Name
                    'MonitorInfo' = $monitors
                }
                return $output
            } else {
                write-verbose "$FunctionName`: No WMI data found for $computer"
            }
        }
    }
}
