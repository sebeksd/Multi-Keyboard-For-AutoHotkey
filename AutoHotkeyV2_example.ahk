;Requires AutoHotkey v2.0 - example thanks to TarkanV
#SingleInstance Force
Persistent
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_InitialWorkingDir  ; Ensures a consistent starting directory.

; you can uncomment next lines to run MultiKB_For_AutoHotkey every time this script is started (remember to set up correct path to exe)
;if !ProcessExist("MultiKB_For_AutoHotkey.exe")
;	Run "C:\PATH_TO_EXE\MultiKB_For_AutoHotkey.exe"



; do not modify 
OnMessage(1325, MsgFunc)
return

; do not modify
MsgFunc(wParam, lParam, msg, hwnd)
{
  OnUniqueKeyboard(wParam, lParam & 0xFF, (lParam & 0x100) > 0, (lParam & 0x200) > 0, (lParam & 0x400) > 0, (lParam & 0x800) > 0, (lParam & 0x1000) > 0, (lParam & 0x2000) > 0, (lParam & 0x4000) > 0, (lParam & 0x8000) > 0)  	
}

; KeyboardNumber - configured by you in MultiKB_For_AutoHotkey, this identify keyboard device
; VKeyCode - Key Code, https://www.autohotkey.com/docs/v2/KeyList.htm
; IsDown - is key pressed or released, use "if (!IsDown)" if you like to register only key up, without this your code will be executed twice on key down and key up
; WasDown - like IsDown but this is previous state of this key
; IsExtended - is it normal or extended key (multimedia key, right alt/ctrl etc.)
; LeftCtrl, RightCtrl, LeftAlt, RightAlt, Shift (any) - is corresponding "control key" pressed at the same time
OnUniqueKeyboard(KeyboardNumber, VKeyCode, IsDown, WasDown, IsExtended, LeftCtrl, RightCtrl, LeftAlt, RightAlt, Shift)
{
	; Test message generated on unique configured keyboard, remove after your sure that it is working fine
	;MsgBox "Keyboard: " KeyboardNumber "`nKey: " VKeyCode "`nIsDown: " (IsDown ? "yes" : "no") "`nWasDown: " (WasDown ? "yes" : "no") "`nIsExtended: " (IsExtended ? "yes" : "no") "`nLeftCtrl: " (LeftCtrl ? "yes" : "no") "`nRightCtrl: " (RightCtrl ? "yes" : "no") "`nLeftAlt: " (LeftAlt ? "yes" : "no") "`nRightAlt: " (RightAlt ? "yes" : "no") "`nShift: " (Shift ? "yes" : "no")

	; example, remove, keyboard 1 - "G" + RightCtrl + LeftAlt + Shift
	; if (KeyboardNumber = 1 && VKeyCode = 71 && RightCtrl && LeftAlt && Shift)
	;	MsgBox "Test message"
	

	; ---> Add your code below <---

}