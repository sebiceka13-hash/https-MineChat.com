Option Explicit
' Mine Chat - start server hidden (if needed) and open the browser when ready.
Dim shell, q, cmdLine, i, up
Set shell = CreateObject("WScript.Shell")
q = Chr(34)
shell.CurrentDirectory = "C:\Users\sebic\OneDrive\Desktop\mine chat"
cmdLine = q & "C:\Program Files\nodejs\node.exe" & q & " --env-file-if-exists=.env server.js"

If Not ServerUp() Then
  shell.Run cmdLine, 0, False
End If

up = False
For i = 1 To 30
  If ServerUp() Then
    up = True
    Exit For
  End If
  WScript.Sleep 500
Next

shell.Run "https://minechat", 1, False

Function ServerUp()
  On Error Resume Next
  Dim req, ok
  ok = False
  Set req = CreateObject("WinHttp.WinHttpRequest.5.1")
  req.SetOption 4, 13056
  req.SetTimeouts 1000, 1000, 2000, 4000
  req.Open "GET", "https://localhost/api/status", False
  req.Send
  If Err.Number = 0 Then
    If req.Status = 200 Then ok = True
  End If
  Err.Clear
  On Error GoTo 0
  ServerUp = ok
End Function