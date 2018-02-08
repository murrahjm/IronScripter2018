#function for each 'parameter set' of options.  does the command and crafts the output object
#primary function does parameter validation and calls correct helper

#helper function for parameter validation to check if current session has elevated rights.
#required for "-b" netstat option
Function IsAdmin {
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin=$prp.IsInRole($adm)
    If ($IsAdmin){
        $True
    } else {
        Throw [System.Management.Automation.ValidationMetadataException] "The requested operation requires elevation."
    }
}
#templates for select-string
$connectiontemplateStringTemplate = @'
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:54987} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:55029} {State:FIN_WAIT_2} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:55062} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:49671} {ForeignIP:vmware-localhost}:{ForeignPort:49695} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50015} {ForeignIP:pdsccminf01corp}:{ForeignPort:10123} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50426} {ForeignIP:pdprtsrv03corp}:{ForeignPort:56586} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50430} {ForeignIP:isi-isilonprdsmb-13}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50432} {ForeignIP:isi-isilonprdsmb-13}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50433} {ForeignIP:10.96.200.74}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50435} {ForeignIP:10.96.200.74}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50438} {ForeignIP:isi-fsit01-corp-7}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50441} {ForeignIP:isi-fs01-corp-12}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50444} {ForeignIP:isi-fs01-corp-12}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:50526} {ForeignIP:10.96.117.236}:{ForeignPort:https} {State:ESTABLISHED} {Template:Not Applicable}
'@
$networkconnectionsStringTemplate = @'
 {Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:22} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}
 {Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:135} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}
 {Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55419} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT}
 {Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:127.0.0.1}:{ForeignPort:54987} {State:ESTABLISHED}
 {Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:10964} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:CLOSE_WAIT}
 {Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49667} {ForeignIP:[::]}:{ForeignPort:0} {State:FIN_WAIT_2}
 {Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:123} {ForeignIP:\*}:{ForeignPort:\*} 
'@



Function Get-NetworkStatistics {
    Param(
        [Parameter(ParameterSetName='ethernetstats')]
        [Alias('e')]
        [Switch]$EthernetStats,
        [Parameter(ParameterSetName='ethernetstats')]
        [Alias('s')]
        [Switch]$PerProtocolStats,

        [Parameter(ParameterSetName='routetable')]
        [Alias('r')]
        [Switch]$RoutingTable,

        [Parameter(ParameterSetName='networkconnections')]
        [Alias('a')]
        [Switch]$Connections,
        [Parameter(ParameterSetName='networkconnections')]
        [Alias('o')]
        [Switch]$ProcessInfo,
        [Parameter(ParameterSetName='networkconnections')]
        [Alias('b')]
        [ValidateScript({IsAdmin})]
        [Switch]$ExecutableName,
        [Parameter(ParameterSetName='networkconnections')]
        [Alias('q')]
        [Switch]$BoundPorts,
        
        [Parameter(ParameterSetName='connectiontemplate')]
        [Alias('y')]
        [Switch]$ConnectionTemplate,

        [Parameter(ParameterSetName='networkconnections')]
        [Parameter(ParameterSetName='connectiontemplate')]
        [Parameter(ParameterSetName='')]
        [Alias('n')]
        [Switch]$NoDNSResolution
    )
    $ErrorActionPreference = 'Stop'
    $cmdstring = "$($env:SystemRoot)\system32\NETSTAT.EXE"
    if (! (test-path $cmdstring)){
        throw "netstat command not found"
    }
    Foreach ($parameter in $PSBoundParameters.keys){
        Switch ($parameter) {
            'ethernetstats' {$cmdstring += ' -e'}
            'PerProtocolStats' {$cmdstring += ' -s'}
            'RoutingTable' {$cmdstring += ' -r'}
            'Connections' {$cmdstring += ' -a'}
            'ProcessInfo' {$cmdstring += ' -o'}
            'ExecutableName' {$cmdstring += ' -b'}
            'BoundPorts' {$cmdstring += ' -q'}
            'ConnectionTemplate' {$cmdstring += ' -y'}
            'NoDNSResolution' {$cmdstring += ' -n'}
        }
    }
    write-verbose "Running command`:  $cmdstring"
    $scriptblock = [scriptblock]::Create($cmdstring)
    $Results = invoke-command -ScriptBlock $scriptblock
    switch ($PSCmdlet.ParameterSetName) {
        'connectiontemplate' {$output = $Results | Select-Object -Skip 4 | ConvertFrom-String -TemplateContent $connectiontemplateStringTemplate}
        'networkconnections' {$output = $Results | Select-Object -Skip 4 | ConvertFrom-String -TemplateContent $networkconnectionsStringTemplate}
        'routetable' {$output = $Results | ConvertFrom-String -TemplateContent $routetableStringTemplate}
        'ethernetstats' {$output = $Results | ConvertFrom-String -TemplateContent $ethernetstatsStringTemplate}
    }
    $output
}
Get-NetworkStatistics -a -n -Verbose
