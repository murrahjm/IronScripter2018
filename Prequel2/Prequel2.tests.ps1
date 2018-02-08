$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe -Name "Unit Testing Get-ComputerInfo" -Fixture {
    Context -Name "Mock Functions" -Fixture {
        Mock -CommandName Get-CimInstance -MockWith {
            [pscustomobject]@{
                name = 'Microsoft Windows 10 Enterprise'
                Version = '10.0.15063'
                ServicePackMajorVersion = 0
                ServicePackMinorVersion = 0
                Manufacturer = 'Pester, Inc.'
                Locale = 0409
                FreePhysicalMemory = 3517084
                TotalVirtualMemorySize = 9970252
                FreeVirtualMemory = 3555120
            }
        } -ParameterFilter { $ClassName -and $ClassName -eq "Win32_OperatingSystem"} #Get-CimInstance Mock
        Mock -CommandName Get-CimInstance -MockWith {
            [pscustomobject]@{
                DeviceID = 'C:'
                Description = 'Mocked Disk 1'
                Size = 246936498176
                FreeSpace = 108592111616
                Compressed = $False
            }#PSCustomObject
            [pscustomobject]@{
                DeviceID = 'D:'
                Description = 'Mocked Disk 2'
                Size = 5364514816
                FreeSpace = 5364465664
                Compressed = $False
            }#PSCustomObject

        } -ParameterFilter { $ClassName -and $ClassName -eq "Win32_LogicalDisk"} #Get-CimInstance Mock#Mock Get-Ciminstance
        
        $Result = Get-ComputerInfo
        It -name "Assert Mock called - Get-CimInstance" -test {
            Assert-MockCalled -CommandName Get-CimInstance -Times 1 -ParameterFilter { $ClassName -and $ClassName -eq "Win32_OperatingSystem"}
            Assert-MockCalled -CommandName Get-CimInstance -Times 2
        }#It
        It -name "Result is not null" -test{
            $Result | Should not beNullOrEmpty
        }#It
        It -name "Disk Description is mocked" -test{
            $Result.diskinfo[0].DriveType | Should be "Mocked Disk 1"
            $Result.diskinfo[1].DriveType | Should be "Mocked Disk 2"
        }#It
        It -name "ComputerName matches env:ComputerName" -test{
            $Result.ComputerName | Should be $env:ComputerName
        }#It
        It -name "Manufacturer is mocked" -test {
            $Result.OSManufacturer | Should be 'Pester, Inc.'
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