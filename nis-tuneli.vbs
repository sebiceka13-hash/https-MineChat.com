' Mine Chat - Nis linkun publik (pa terminal)
Option Explicit
Dim shell, fso, base, logFile, cmd, i, content, url, parts, p, line

base = "C:\Users\sebic\OneDrive\Desktop\mine chat"
logFile = base & "\tuneli.log"
Set fso = CreateObject("Scripting.FileSystemObject")

If fso.FileExists(logFile) Then fso.DeleteFile logFile, True

Set shell = CreateObject("WScript.Shell")

cmd = "cmd /c " & Chr(34) & base & "\cloudflared.exe tunnel --no-autoupdate --url https://localhost:443 --no-tls-verify > " & Chr(34) & logFile & Chr(34) & " 2>&1" & Chr(34)
shell.Run cmd, 0, False

Wscript.Sleep 3000

url = ""
For i = 1 To 40
  If fso.FileExists(logFile) Then
    content = fso.OpenTextFile(logFile, 1).ReadAll
    If InStr(content, "trycloudflare.com") > 0 Then
      parts = Split(content, "https://")
      For Each p In parts
        If InStr(p, "trycloudflare.com") > 0 Then
          line = Split(p, " ")(0)
          line = Split(line, vbCr)(0)
          line = Split(line, vbLf)(0)
          url = "https://" & Trim(line)
          Exit For
        End If
      Next
    End If
  End If
  If url <> "" Then Exit For
  Wscript.Sleep 1000
Next

If url = "" Then
  MsgBox "Nuk u arrit te gjendet linku." & vbCrLf & "Shiko skedarin: " & logFile, vbExclamation, "Mine Chat"
Else
  Dim clip
  Set clip = CreateObject("HTMLFile")
  clip.parentWindow.clipboardData.setData "Text", url
  MsgBox "Linku yt publik:" & vbCrLf & vbCrLf & url & vbCrLf & vbCrLf & "U kopjua ne clipboard.", vbInformation, "Mine Chat - Link publik"
End If
