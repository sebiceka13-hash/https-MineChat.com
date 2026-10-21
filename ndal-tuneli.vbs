' Mine Chat - Ndal linkun publik
Option Explicit
Dim shell, wmi, processes, proc, killed
Set shell = CreateObject("WScript.Shell")
Set wmi = GetObject("winmgmts:\" & "." & "\root\cimv2")
Set processes = wmi.ExecQuery("Select * from Win32_Process where Name='cloudflared.exe'")
killed = 0
For Each proc In processes
  proc.Terminate
  killed = killed + 1
Next
If killed > 0 Then
  MsgBox "Linku publik u mbyll." & vbCrLf & "Mine Chat vazhdon te punoje vetem ne kompjuterin tend.", vbInformation, "Mine Chat"
Else
  MsgBox "Nuk ishte aktiv asnje link publik.", vbInformation, "Mine Chat"
End If
