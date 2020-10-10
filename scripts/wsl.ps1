start-transcript -path c:\windows\temp\wsl.log -append
$ProgressPreference = 'SilentlyContinue'
if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -online -ErrorAction SilentlyContinue).State -eq 'Enabled') {
    write-output "Setting WSL 2 as default version"
    wsl --set-default-version 2
    Write-Output "Downloading ubuntu2004"
    Invoke-WebRequest -Uri https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -OutFile \wsl\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -UseBasicParsing | out-null
#    Write-Output "Expanding ubuntu2004"
#    Expand-Archive c:\windows\temp\ubuntu2004.zip 'c:\Program Files\Ubuntu2004' -Force
    write-output "Installing the ubuntu2004 distro"
    new-item -path \wsl -ItemType "directory"
    Start-Process -FilePath 'C:\WINDOWS\system32\wsl.exe' -ArgumentList "--import","Ubuntu-20.04","\wsl","\wsl\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz" -Wait
    write-output "listing installed distros"
    wsl -l -v
    write-output "Setting ubuntu2004 to WSL v2"
    wsl --set-version Ubuntu-20.04 2
    wsl --set-default Ubuntu-20.04
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


## wsl packages
