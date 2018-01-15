Function Get-ComputerInfo {
    Param (
        [Parameter(Position=1,Mandatory=$True, ValueFromPipelineByPropertyName)]
        [alias('Computer','Host','Hostname','Server','ServerName')]
        [String[]]$ComputerName,

        [pscredential]$Credential
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
                $Monitor = Get-WMIObject -Namespace root\wmi -Class wmiMonitorID -Credential $Credential
                $Computer = Get-WMIObject -Class Win32_ComputerSystem -Credential $Credential
                If (! $Monitor){Throw "No monitor data available"}
                If (! $Computer){Throw "No computer data available"}
            } Catch {
                Write-verbose "$FunctionName`: Unable to retrieve data via WMI method.  Attempting WSMan connection."
                write-verbose "$FunctionName`: Error message $_"
            }
            Try {
                $Session = New-PSSession -ComputerName $Computer -Credential $Credential
                $Monitor = Invoke-command -ScriptBlock {Get-WMIObject -namespace root\wmi -class wmiMonitorID} -Session $Session
                $Computer = Invoke-command -ScriptBlock {Get-WMIObject -class Win32_ComputerSystem} -Session $Session
            } Catch {
                write-error "Unable to connect to $Computer"
                Remove-PSSession $Session
                return
            }
        }
    }
}