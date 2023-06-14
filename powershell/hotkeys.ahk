#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%"
#Warn
SendMode Input

; Hibernate mode with Hotkey - Win+Shift+H
#+h::
DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return

; Sleep mode - Win+Shift+S
#+s::
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return

; Shutdown mode with Hotkey - Win+Shift+P (P, like PowerDown)
#+p::
Shutdown, 8
return

; Open Chrome
#C::
Run, C:\Program Files\Google\Chrome\Application\chrome.exe
return

; Open Code
#V::
Run, C:\Users\jokerwrld\AppData\Local\Programs\Microsoft VS Code\Code.exe
return

; Open Explorer
#E::
Run, C:\Windows\explorer.exe
return

; Open Telegram
#T::
Run, C:\Users\jokerwrld\AppData\Roaming\Telegram Desktop\Telegram.exe
return

; Open Windows Terminal
^!T::
Run, C:\Users\jokerwrld\AppData\Local\Microsoft\WindowsApps\wt.exe
return

; Close Active Window
::                                               ; Long press (> 0.5 sec) on Esc closes window - but if you change your mind you can keep it pressed for 3 more seconds
    KeyWait, Escape, T0.5                               ; Wait no more than 0.5 sec for key release (also suppress auto-repeat)
    If ErrorLevel                                       ; timeout, so key is still down...
        {
            KeyWait, Escape, T3                         ; Wait no more than 3 more sec for key to be released
            If !ErrorLevel                              ; No timeout, so key was released
                {
                    PostMessage, 0x112, 0xF060,,, A     ; ...so close window
                    Return
                }
                                                        ; Otherwise,
            KeyWait, Escape                             ; Wait for button to be released
                                                        ; Then do nothing...
            Return
        }
    Send {Esc}
Return

; Move Window to Left Monitor
<#+J::
Send #+{Left}
return

; Move Window to Right Monitor
<#+L::
Send #+{Right}
return

; Move Window to Bottom-Left Corner
^#M::
#Numpad1::
	MoveIt(1)
	return

; Move Window to Bottom Side
^#K::
#Down::
	MoveIt(2)
	return

; Move Window to Bottom-Right Corner
^#>::
#Numpad3::
	MoveIt(3)
	return

; Move Window to Left Side
^#J::
#Left::
	MoveIt(4)
	return

; Maximize/Restore Window Toggle
#+K::
	MoveIt(5)
	return

; Move Window to Right Side
^#L::
#Right::
	MoveIt(6)
	return

; Move Window to Top-Left Corner
^#U::
#Numpad7::
	MoveIt(7)
	return

; Move Window to Top Side
^#I::
#Up::
	MoveIt(8)
	return

; Move Window to Top-Right Corner
^#O::
#Numpad9::
	MoveIt(9)
	return

; Function to Move Windows Across Current Monitor
MoveIt(Q)
{
  ; Get the windows pos
	WinGetPos,X,Y,W,H,A,,,
	WinGet,M,MinMax,A

  ; Calculate the top center edge
  CX := X + W/2
  CY := Y + 10

;  MsgBox, X: %X% Y: %Y% W: %W% H: %H% CX: %CX% CY: %CY%

  SysGet, Count, MonitorCount

  num = 1
  Loop, %Count%
  {
    SysGet, Mon, MonitorWorkArea, %num%

    if( CX >= MonLeft && CX <= MonRight && CY >= MonTop && CY <= MonBottom )
    {
		MW := (MonRight - MonLeft)
		MH := (MonBottom - MonTop)
		MHW := (MW / 2)
		MHH := (MH / 2)
		MMX := MonLeft + MHW
		MMY := MonTop + MHH

		if( M != 0 )
			WinRestore,A

		if( Q == 1 )
			WinMove,A,,MonLeft,MMY,MHW,MHH
		if( Q == 2 )
			WinMove,A,,MonLeft,MMY,MW,MHH
		if( Q == 3 )
			WinMove,A,,MMX,MMY,MHW,MHH
		if( Q == 4 )
			WinMove,A,,MonLeft,MonTop,MHW,MH
		if( Q == 5 )
		{
			if( M == 0 )
				WinMaximize,A
			else
				WinRestore,A
		}
		if( Q == 6 )
			WinMove,A,,MMX,MonTop,MHW,MH
		if( Q == 7 )
			WinMove,A,,MonLeft,MonTop,MHW,MHH
		if( Q == 8 )
			WinMove,A,,MonLeft,MonTop,MW,MHH
		if( Q == 9 )
			WinMove,A,,MMX,MonTop,MHW,MHH
        return
    }

    num += 1
  }

return
}

; Set English Layout
#+E::
   SetDefaultKeyboard(0x0409)
return

; Set Russian Layout
#+R::
   SetDefaultKeyboard(0x0419)
return

; Set Ukranian Layout
#+U::
   SetDefaultKeyboard(0x0422)
return

SetDefaultKeyboard(LocaleID){
	Global
	SPI_SETDEFAULTINPUTLANG := 0x005A
	SPIF_SENDWININICHANGE := 2
	Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0)
	VarSetCapacity(Lan%LocaleID%, 4, 0)
	NumPut(LocaleID, Lan%LocaleID%)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", &Lan%LocaleID%, "UInt", SPIF_SENDWININICHANGE)
	WinGet, windows, List
	Loop %windows% {
		PostMessage 0x50, 0, %Lan%, , % "ahk_id " windows%A_Index%
	}
}
