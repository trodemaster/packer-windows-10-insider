$ProgressPreference = 'SilentlyContinue'
start-transcript -path c:\windows\temp\packages.log -append

if(-not(test-path "C:\ProgramData\chocolatey\choco.exe")){
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco install -y autologon | Out-Null
choco install -y notepadplusplus | Out-Null
choco install -y 7zip | Out-Null
choco install -y git | out-null
choco install -y googlechrome | Out-Null
choco install -y powershell-core | Out-Null
choco install -y ultradefrag | out-null
choco install -y sdelete | out-null
choco install -y choco microsoft-windows-terminal | out-null

Stop-Transcript

exit 0

