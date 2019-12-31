# Powershell version of install windows update via task scheduler
# This script creates a logon task to run windows updates.
# Depends on packer windows-restart to start the taks and stop winrm. 
# After all updaets are instaled winrm is started and the login task is removed. 

# setup window name and script name variable
$scriptname="windows-update-winrm.ps1"
$host.ui.RawUI.WindowTitle = "$scriptname"

# start logging
start-transcript -path c:\windows\temp\windows-update-winrm.log -append

# Report the IE version Installed
Write-output ("Installed IE Version currently is " + (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer').Version)

# Report the powershell version installed
$powershellversion=$PSVersionTable.PSVersion
write-output "Powershell version $powershellversion installed"

# Report the version of windows update agent
$wu_agent=(get-command C:\windows\system32\wups2.dll).version
write-output "Windows Update agent is version $wu_agent"

# Check to see if scheduled task called $scriptname exists
if (schtasks /query /tn $scriptname 2>$null ) {
  write-output "Checking for updates...."
  Get-WUInstallerStatus
  if (Get-WindowsUpdate -NotTitle "Printer")
  {
    write-output "Starting Windows update installation..."

    # run windows updates
    Install-WindowsUpdate -IgnoreUserInput -AcceptALL -IgnoreReboot -verbose  

    # restart after every insstall of updates
    stop-transcript
    restart-computer
  } else {
    write-output "No updates found..."

    #remove scheduled task
    schtasks /delete /tn $scriptname /f

    # start winrm service and set to autostart
    set-service -name winrm -startuptype automatic
    stop-transcript
    restart-computer
  }
} else {
    # first run of script
    # setup windows updater components
    $ErrorActionPreference = 'Stop'
    # install nuget
    write-output "Installing NuGet"
    
    [int]$attempts = 0
    do {
        try {
            $attempts +=1
            Get-PackageProvider -Name NuGet -ForceBootstrap
            if (-not([string](Get-PackageProvider).name -match "NuGet")) { throw "Error installing NuGet" }
            break
        } catch {
            write-host "Problem installing NuGet `tAttempt $attempts `
                       `n`tException: " $_.Exception.Message
            start-sleep -s 20
        }
    }
    while ($attempts -lt 10)
    if ($attempts -ge 10) {
        write-host "NuGet failed to install!!"
        exit 1
    }
    
    # allow repo install
    write-output "Adding PSGallery repo"
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
    # install PSWindowsUpdate
    write-output "Installing PSWindowsUpdate"
    Install-Module -Name PSWindowsUpdate -Confirm:$false | out-null
    write-output "Installed PSWindowsUpdate"

    #Get-WindowsUpdate 
    write-output "Modern windows update tools installed..."
    
    # set winrm to manual start to prevent packer from connecting on reboot
    Set-Service -Name winrm -StartupType Manual
    
    # disable windows fast boot to prevent bluescreen durring patching
    Set-ItemProperty -Path "registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0

    # if schedled task does not exist create it
    Write-output "Creating scheduled task to start $scriptname with proper elevation"

    # setup task scheduler login item to process this script next boot
    schtasks /create /ru "BUILTIN\administrators" /sc ONLOGON /tn $scriptname /tr "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\windows\temp\$scriptname" /rl highest /f /np
 }
stop-transcript
exit 0