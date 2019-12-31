Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server