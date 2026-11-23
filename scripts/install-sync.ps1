param([int]$IntervalMinutes=2)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
$shell=(Get-Command pwsh.exe).Source
$script=Join-Path $PSScriptRoot 'publish.ps1'
$action=New-ScheduledTaskAction -Execute $shell -Argument ('-NoProfile -NonInteractive -WindowStyle Hidden -File "'+$script+'"') -WorkingDirectory $repoRoot
$trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes($IntervalMinutes) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
$principal=New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$settings=New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 3)
Register-ScheduledTask -TaskName 'CareerDocuments-Publish' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Publish the two configured saved Word documents to GitHub Pages when their hashes change.' -Force | Select-Object TaskName,State
