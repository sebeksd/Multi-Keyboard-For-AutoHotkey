﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; do not modify 
OnMessage(1325 , "MsgFunc")
return

MsgFunc(wParam, lParam, msg, hwnd)
{
	; do not modify
  OnUniqueKeyboard(wParam, lParam & 0xFF, (lParam & 0x100) > 0, (lParam & 0x200) > 0, (lParam & 0x400) > 0, (lParam & 0x800) > 0, (lParam & 0x1000) > 0, (lParam & 0x2000) > 0, (lParam & 0x4000) > 0, (lParam & 0x8000) > 0)  	
}

; KeyboardNumber - configured by you in MultiKB_For_AutoHotkey, this identify keyboard device
; VKeyCode - Key Code, https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes 
; IsDown - is this press or release
; WasDown - like IsDown but this is previous state of this key
; IsExtended - is it normal or extended key (multimedia key, right alt/ctrl etc.)
OnUniqueKeyboard(KeyboardNumber, VKeyCode, IsDown, WasDown, IsExtended, LeftCtrl, RightCtrl, LeftAlt, RightAlt, Shift)
{
	; Test message generated on unique configured keyboard, remove after your sure that it is working fine
	;MsgBox % "Keyboard: " . KeyboardNumber . " Key: " . VKeyCode . " IsDown: " . (IsDown ? "yes" : "no") . " WasDown: " . (WasDown ? "yes" : "no") . " IsExtended: " . (IsExtended ? "yes" : "no") . " LeftCtrl: " . (LeftCtrl ? "yes" : "no") . " RightCtrl: " . (RightCtrl ? "yes" : "no") . " LeftAlt: " . (LeftAlt ? "yes" : "no") . " RightAlt: " . (RightAlt ? "yes" : "no") . " Shift: " . (Shift ? "yes" : "no")

	; example, keyboard 1 - "G" + RightCtrl + LeftAlt + Shift
	if (KeyboardNumber = 1 and VKeyCode = 71 and RightCtrl and LeftAlt and Shift)
		MsgBox "Test message"

	; Add your code here

}