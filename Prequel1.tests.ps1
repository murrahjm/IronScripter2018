$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe -Name "Unit Testing Get-ComputerInfo" -Fixture {
    Context -Name "Mock Functions" -Fixture {
        Mock -CommandName Get-CimInstance -MockWith {
            [pscustomobject]@{
                name = $ComputerName
                model = 'PHILIPS'
            }
        } -ParameterFilter { $ClassName -and $ClassName -eq "Win32_ComputerSystem"} #Get-CimInstance Mock
        Mock -CommandName Get-CimInstance -MockWith {
            [pscustomobject]@{
                SerialNumber = '1234568'
            }
        } -ParameterFilter { $ClassName -and $ClassName -eq "Win32_BIOS"} #Get-CimInstance Mock
        Mock -CommandName Get-CimInstance -MockWith {
            [pscustomobject]@{
                UserFriendlyName = @('109','111','99','107','101','100')
                SerialNumberID = @('56','54','55','53','51','48','57')
            }#PSCustomObject
        } -ParameterFilter { $ClassName -and $ClassName -eq "wmiMonitorID"} #Get-CimInstance Mock#Mock Get-Ciminstance
        
        $Result = Get-ComputerInfo
        It -name "Assert Mock called - Get-CimInstance" -test {
            Assert-MockCalled -CommandName Get-CimInstance -Times 1 -ParameterFilter { $ClassName -and $ClassName -eq "Win32_ComputerSystem"}
            Assert-MockCalled -CommandName Get-CimInstance -Times 2
        }#It
        It -name "Result is not null" -test{
            $Result | Should not beNullOrEmpty
        }#It
        It -name "MonitorType is mocked" -test{
            $Result.monitorinfo.MonitorType | Should be "Mocked"
        }#It
        It -name "ComputerName matches env:ComputerName" -test{
            $Result.ComputerName | Should be $env:ComputerName
        }#It
        It -name "ComputerSerial is mocked" -test {
            $Result.ComputerSerial | Should be '1234568'
        }#It
        It -name "MonitorSerial is mocked" -test {
            $Result.monitorinfo.MonitorSerial | Should be '8675309'
        }#It
        It -name "Processes computername parameter from pipeline input" -test {
            $result = 'computer1','computer2' | get-computerinfo
            $result[0].Computername | should be 'computer1'
            $result[1].Computername | should be 'computer2'
        }
        It -name "Processes computername parameter as property of input object" -test {
            $inputobject = [pscustomobject]@{Computername='computer1'}
            $Result = $inputobject | get-computerinfo
            $result.Computername | should be 'computer1'
        }
        It -name "Processes multiple computernames as properties of input objects with alias" -test {
            $inputarray = @()
            $inputarray += [pscustomobject]@{host='computer1'}
            $inputarray += [pscustomobject]@{host='computer2'}
            $Result = $inputarray | get-computerinfo
            $result[0].Computername | should be 'computer1'
            $Result[1].Computername | should be 'computer2'
        }
    }#Context Mock Functions
    Context -Name "No Mocked Functions" -Fixture {
        $Result = Get-ComputerInfo
        It -name "Result is not null" -test{
            $Result | Should not beNullOrEmpty
        }#It
    }#Context no mocked functions
}#Describe