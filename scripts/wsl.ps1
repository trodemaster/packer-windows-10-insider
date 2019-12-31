start-transcript -path c:\windows\temp\wsl.log -append
$ProgressPreference = 'SilentlyContinue'
if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -online -ErrorAction SilentlyContinue).State -eq 'Enabled') {
    write-output "Setting WSL 2 as default version"
    wsl --set-default-version 2
    Write-Output "Downloading ubuntu1804"
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile c:\windows\temp\ubuntu1804.zip -UseBasicParsing | out-null
    Write-Output "Expanding ubuntu1804"
    Expand-Archive c:\windows\temp\ubuntu1804.zip 'c:\Program Files\Ubuntu1804' -Force
    write-output "Installing the ubuntu1804 distro"
    Start-Process -FilePath 'C:\Program Files\Ubuntu1804\ubuntu1804.exe' -ArgumentList "install","--root" -Wait
    write-output "listing installed distros"
    wsl -l -v
    write-output "Setting ubuntu1804 to WSL v2"
    wsl --set-version Ubuntu-18.04 2
    Start-Sleep -Seconds 4
} else {
    Write-Output "Enabling wsl"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction SilentlyContinue
    write-output "enabling virtual machine platform"
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction SilentlyContinue
    Write-Output "VirtualMachinePlatform feature enabled. Reboot needed..."
}
stop-transcript
exit 0