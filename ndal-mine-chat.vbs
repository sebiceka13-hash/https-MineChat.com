Option Explicit
' Ndal Mine Chat. Asnje dritare e ze nuk shfaqet.
Dim shell, q
Set shell = CreateObject("WScript.Shell")
q = Chr(34)
shell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File " & q & "C:\Users\sebic\OneDrive\Desktop\mine chat\ndal-serveri.ps1" & q, 0, True
