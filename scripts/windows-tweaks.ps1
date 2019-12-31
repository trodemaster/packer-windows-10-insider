# windows cleanup

# test to see if this is a desktop version of windows
$windesktop = (gwmi win32_operatingsystem).OperatingSystemSKU -notmatch "(\b[7-9]|10|1[2-5]|1[7-9]|2[0-5])"                           
if ($windesktop) { 
  write-output "This is a desktop version of windows" 
} 

write-output "Disable Hybernation"
powercfg -hibernate OFF

write-output  "configure screen saver"
Set-ItemProperty -Path "registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveActive -Value 0

write-output  "Enable administrator account"
net user administrator /active:yes

write-output  "Disable firewall"
netsh advfirewall set allprofiles state off

write-output  "supress network location Prompt"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

## Optimize IPv6 settings
write-output  "disable privacy IPv6 addresses"
netsh interface ipv6 set privacy state=disabled store=active
netsh interface ipv6 set privacy state=disabled store=persistent

write-output  "enable EUI-64 addressing"
netsh interface ipv6 set global randomizeidentifiers=disabled store=active
netsh interface ipv6 set global randomizeidentifiers=disabled store=persistent

## Disable IPv6 transistion service interfaces
netsh interface teredo set state disabled
netsh interface isatap set state disabled

# disable smb 1 Protocol
dism /online /norestart /disable-feature /featurename:SMB1Protocol

# Force clear any dhcp client lease
$NIC_INTERFACEGUIDS = (gwmi win32_networkadapter -Property GUID).GUID | Where-Object { $_ }
foreach ($NIC_INTERFACEGUID in $NIC_INTERFACEGUIDS) {
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$NIC_INTERFACEGUID" -name "ReleaseOnShutDown" -value 2 -force -EA 0
}

write-output  "Enable Remote Desktop"
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1, 1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null

#write-output  "Clear windows autologon"
#Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -EA 0
#Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -EA 0
#Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -EA 0
#Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserPassword -EA 0
#Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -EA 0

write-output  "Clear WSUS settings"
Remove-Item -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -recurse -EA 0

write-output "Disable superfetch"
Set-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnablePrefetcher -Value 0 -EA 0
Set-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Value 0 -EA 0
Set-Service -Name sysmain -StartupType Disabled

write-output "Disable system restore"
Disable-ComputerRestore -Drive "C:\"

#write-output  "Enable remote command policy"
#Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord
#Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name FilterAdministratorToken -Value 1 -Type DWord
    
# sysprep with wmf 5 fix
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\StreamProvider' -Force | New-ItemProperty -Name LastFullPayloadTime -Value 0 -Type DWord -Force

# set ntp to sync time before domain join
Write-Output "Setting System Time Zone to UTC `r"
tzutil.exe /s "UTC"
