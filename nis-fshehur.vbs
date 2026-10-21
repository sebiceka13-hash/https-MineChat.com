Option Explicit
' Nis serverin Mine Chat krejt pa dritare. Nuk ka asnje dritare per te mbyllur.
Dim shell, appdir, cmdLine
Set shell = CreateObject("WScript.Shell")
appdir = "C:\Users\sebic\OneDrive\Desktop\mine chat"
shell.CurrentDirectory = appdir
cmdLine = Chr(34) & "C:\Program Files\nodejs\node.exe" & Chr(34) & " --env-file-if-exists=.env server.js"
shell.Run cmdLine, 0, False
