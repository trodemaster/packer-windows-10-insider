# windows powershell bootstrap script
$host.ui.RawUI.WindowTitle = "Bootstrapping Windows"

## Identify the version of windows

# test to see if this is a desktop version of windows
$windesktop = (gwmi win32_operatingsystem).OperatingSystemSKU -notmatch "(\b[7-9]|10|1[2-5]|1[7-9]|2[0-5])"                           
if ($windesktop) 
{ 
    write-output "This is a desktop version of windows" 
}

# get the windows kernel version
$KERNELVERSION = [Environment]::OSVersion.Version

# example test for reference.
# 6.1 = Windows 7 & 2008 R2
# 6.2 = Windows 8 & Server 2012
# 6.3 = Windows 8.1 & Server 2012 R2
# 10.0 = Windows 10 & Server 2016
#if ($KERNELVERSION -ge (new-object 'Version' 10,0)) {
#  write-output "Windows 10 kernel version"
#} 

# supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# set network to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private 
#need to test below
#Get-NetAdapter | Set-NetConnectionProfile -NetworkCategory Private

# block windows app store from loading apps that break sysprep
if ($KERNELVERSION -ge (new-object 'Version' 6,3)) {
  new-Item -Path "registry::HKLM\Software\Policies\Microsoft\Windows" -Name CloudContent -force
  New-Itemproperty -Path "registry::HKLM\Software\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -Value 1 -PropertyType "DWord" -Force
} 


# Make administrator user active for desktop OS
net user administrator /active:yes

# disable windows defender CPU hog during build only works on win10
if ($KERNELVERSION -ge (new-object 'Version' 10,0)) {
  Set-MpPreference -DisableRealtimeMonitoring $true -DisableArchiveScanning $true -DisableIOAVProtection $true
} 

# get winrm to startup a bit quicker
set-service -name winrm -startuptype automatic

# configure powersaving and screen saver
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -change -monitor-timeout-ac 0
powercfg -hibernate OFF

New-Itemproperty -Path "registry::HKCU\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -PropertyType "DWord" -Force
New-Itemproperty -Path "registry::HKCU\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 0 -PropertyType "DWord" -Force
New-Itemproperty -Path "registry::HKU\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -PropertyType "DWord" -Force
New-Itemproperty -Path "registry::HKU\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 0 -PropertyType "DWord" -Force

#Stop windows updtes from starting immediatly
$WUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$WUSettings.NotificationLevel=1
$WUSettings.save()

## make sure auto login is enabled and set it if not.
#if ((Get-ItemProperty -path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -EA 0) -ne "1") {
#  Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -Value $env:computername  -type String
#  Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "administrator" -type String
#  Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1" -type String
#  Set-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "" -type String
#}
