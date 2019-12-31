# Cleanup and free disk space
start-transcript -path c:\windows\temp\cleanup_compact.log -append

# Stops the windows update service.  
Stop-Service -Name wuauserv -Force -EA 0 
Get-Service -Name wuauserv

# Delete the contents of windows software distribution.
write-output "Delete the contents of windows software distribution" 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of itcloud apps.
write-output "Delete the contents of itcloud apps" 
Get-ChildItem "C:\users\itcloud\AppData\Local\Packages\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of windows software distribution.
write-output "Delete the contents of user template desktop"
Get-ChildItem "C:\Users\Public\Desktop\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 
 
# Starts the Windows Update Service 
Start-Service -Name wuauserv -EA 0

# use dism to cleanup windows sxs.
write-output "Cleaning up winSXS with dism"
dism /online /cleanup-image /startcomponentcleanup /resetbase /quiet

# Defragment the virtual disk blocks
write-output "Starting to Defragment Disk"
start-process -FilePath 'C:\windows\system32\udefrag.exe' -ArgumentList '--optimize --repeat C:' -wait -verb RunAs
  
# Zero dirty blocks
write-output "Starting to Zero blocks"
New-Item -Path "HKCU:\Software\Sysinternals\SDelete" -force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Sysinternals\SDelete" -Name EulaAccepted -Value "1" -Type DWORD -force
start-process -FilePath 'C:\ProgramData\chocolatey\bin\sdelete64.exe' -ArgumentList '-q -z C:' -wait -EA 0

stop-transcript

exit 0



