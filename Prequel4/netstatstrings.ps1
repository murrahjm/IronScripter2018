#templates for select-string
$connectiontemplateStringTemplate = @'

#Active Connections

# Proto Local Address Foreign Address State Template

{Protocol*:TCP}  {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:54987} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:55029} {State:FIN_WAIT_2} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:vmware-localhost}:{ForeignPort:55062} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:127.0.0.1}:{LocalPort:49671} {ForeignIP:vmware-localhost}:{ForeignPort:49695} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50015} {ForeignIP:pdsccminf01corp}:{ForeignPort:10123} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50426} {ForeignIP:pdprtsrv03corp}:{ForeignPort:56586} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50430} {ForeignIP:isi-isilonprdsmb-13}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50432} {ForeignIP:isi-isilonprdsmb-13}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50433} {ForeignIP:10.96.200.74}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50435} {ForeignIP:10.96.200.74}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50438} {ForeignIP:isi-fsit01-corp-7}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Not Applicable}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50441} {ForeignIP:isi-fs01-corp-12}:{ForeignPort:microsoft-ds} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50444} {ForeignIP:isi-fs01-corp-12}:{ForeignPort:epmap} {State:ESTABLISHED} {Template:Internet}
{Protocol*:TCP}  {LocalIP:10.98.32.200}:{LocalPort:50526} {ForeignIP:10.96.117.236}:{ForeignPort:https} {State:ESTABLISHED} {Template:Not Applicable}
'@

$networkconnectionsStringTemplate = @'
 {Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:22}           {ForeignIP:0.0.0.0}:{ForeignPort:0}         {State:LISTENING}
 {Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:135}          {ForeignIP:0.0.0.0}:{ForeignPort:0}         {State:LISTENING}
 {Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55419}   {ForeignIP:10.96.202.78}:{ForeignPort:135}  {State:TIME_WAIT}
 {Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000}       {ForeignIP:127.0.0.1}:{ForeignPort:54987}   {State:ESTABLISHED}
 {Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:10964}      {ForeignIP:0.0.0.0}:{ForeignPort:0}         {State:CLOSE_WAIT}
 {Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49667}           {ForeignIP:[::]}:{ForeignPort:0}            {State:FIN_WAIT_2}
'@


$test = @'
{Protocol*:TCP} {LocalAddress:0.0.0.0:49164} {ForeignAddress:0.0.0.0:0} {State:LISTENING}
{Protocol*:TCP} {LocalAddress:192.168.1.51:54331} {ForeignAddress:74.125.228.42:80} {State:ESTABLISHED}
{Protocol*:TCP} {LocalAddress:[::]:135} {ForeignAddress:[::]:0}  {State:LISTENING}
{Protocol*:UDP} {LocalAddress:0.0.0.0:443} {ForeignAddress:*:*}{State:\s}
{Protocol*:UDP} {LocalAddress:[::]:3389} {ForeignAddress:*:*}{State:\s}
{Protocol*:UDP} {LocalAddress:[::1]:1900} {ForeignAddress:*:*}{State:\s}
{Protocol*:UDP} {LocalAddress:[fe80::98b9:6db4:216a:2f9f%18]:1900} {ForeignAddress:*:*}{State:\s}
'@

{Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:22} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}{PID:\s}
{Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:135} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}{PID:\s}
{Protocol*:TCP} {LocalIP:0.0.0.0}:{LocalPort:445} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}{PID:\s}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55419} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT} {PID:0}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55422} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT} {PID:0}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55424} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT}{PID:\s}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55426} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT} {PID:0}
{Protocol*:TCP} {LocalIP:10.98.32.200}:{LocalPort:55440} {ForeignIP:10.96.202.78}:{ForeignPort:135} {State:TIME_WAIT} {PID:0}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9000} {ForeignIP:127.0.0.1}:{ForeignPort:54987} {State:ESTABLISHED} {PID:5820}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9535} {ForeignIP:127.0.0.1}:{ForeignPort:50427} {State:ESTABLISHED} {PID:4252}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:9592} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING} {PID:3984}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:10964} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING}{PID:\s}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:10964} {ForeignIP:127.0.0.1}:{ForeignPort:51454} {State:ESTABLISHED} {PID:7384}
{Protocol*:TCP} {LocalIP:127.0.0.1}:{LocalPort:19633} {ForeignIP:0.0.0.0}:{ForeignPort:0} {State:LISTENING} {PID:10412}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49667} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING} {PID:2936}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49668} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING} {PID:3816}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49669} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING}{PID:\s}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49697} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING} {PID:736}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49719} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING} {PID:4992}
{Protocol*:TCP} {LocalIP:[::]}:{LocalPort:49815} {ForeignIP:[::]}:{ForeignPort:0} {State:LISTENING} {PID:744}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:123} {ForeignIP:*}:{ForeignPort:*}{State:\s}  {PID:1320}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:162} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:4388}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:500} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:1544}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:3389} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:1280}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:4500} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:1544}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:5050} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:8448}
{Protocol*:UDP} {LocalIP:0.0.0.0}:{LocalPort:5353} {ForeignIP:*}:{ForeignPort:*}{State:\s} {PID:1452}
