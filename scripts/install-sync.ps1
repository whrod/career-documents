param([int]$IntervalMinutes=2)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
$launcher=Join-Path $env:WINDIR 'System32/wscript.exe'
$script=Join-Path $PSScriptRoot 'run-hidden.vbs'
$action=New-ScheduledTaskAction -Execute $launcher -Argument ('//B //NoLogo "'+$script+'"') -WorkingDirectory $repoRoot
$trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes($IntervalMinutes) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
$principal=New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$settings=New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 3)
Register-ScheduledTask -TaskName 'CareerDocuments-Publish' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Publish the two configured saved Word documents to GitHub Pages when their hashes change.' -Force | Select-Object TaskName,State
