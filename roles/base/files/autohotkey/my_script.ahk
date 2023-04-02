#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#C::
Run, C:\Program Files\Google\Chrome\Application\chrome.exe
return

#V::
Run, C:\Users\jokerwrld\AppData\Local\Programs\Microsoft VS Code\Code.exe
return

#E::
Run, C:\Windows\explorer.exe
return

#T::
Run, C:\Users\jokerwrld\AppData\Roaming\Telegram Desktop\Telegram.exe
return


^!T::
Run, C:\Users\jokerwrld\AppData\Local\Microsoft\WindowsApps\wt.exe
return
