. .\prequel1.ps1
Describe "Prequel 1 tests" {
    It "takes 'computername' parameter from pipeline" {
        $return = 'server2016' | Get-computerinfo
        $return.computername | should be 'localhost'
    }
    It "takes 'computername' parameter as member of pipeline object" {
        $input = new-object psobject -property @{computername = 'server2016'}
        $return = $input | Get-computerinfo
        $return.computername | should be 'localhost'
    }
}
