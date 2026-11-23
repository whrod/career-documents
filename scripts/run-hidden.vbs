Option Explicit
Dim shell, files, folder, repo, powershell, command, result
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
folder = files.GetParentFolderName(WScript.ScriptFullName)
repo = files.GetParentFolderName(folder)
powershell = shell.ExpandEnvironmentStrings("%ProgramFiles%") & "\PowerShell\7\pwsh.exe"
If Not files.FileExists(powershell) Then
  WScript.Quit 2
End If
shell.CurrentDirectory = repo
command = Chr(34) & powershell & Chr(34) & " -NoProfile -NonInteractive -WindowStyle Hidden -File " & Chr(34) & folder & "\publish.ps1" & Chr(34)
' A GUI-subsystem launcher hides the console before PowerShell starts.
result = shell.Run(command, 0, True)
WScript.Quit result
