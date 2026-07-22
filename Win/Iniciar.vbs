Set objShell = CreateObject("WScript.Shell")
Dim fso, scriptDir, ps1File

' Obtém o caminho exato da pasta onde o .vbs está a ser executado
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Define o caminho do seu script PowerShell
ps1File = scriptDir & "\dict.ps1"

' O "0" no final é o comando para executar de forma 100% invisível
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1File & """", 0, False