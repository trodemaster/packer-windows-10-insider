# install vmware tools
$ProgressPreference = 'SilentlyContinue'
start-transcript -path c:\windows\temp\tools.log -append

if(test-path "C:\ProgramData\chocolatey\choco.exe"){
  choco install -y vmware-tools | Out-Null
} else {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install -y vmware-tools | Out-Null
}

Stop-Transcript

exit 0