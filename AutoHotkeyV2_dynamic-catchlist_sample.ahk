#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

; ===================================================================
; --- CONFIGURATION ---
; ===================================================================
MKB_DeviceNumber := 1
MKB_ProcessName := "MultiKB_For_AutoHotkey.exe"
MKB_HWND := ProcessExist(MKB_ProcessName)

if !MKB_HWND {
    MsgBox("ERROR: " . MKB_ProcessName . " process not found. Please run it before this script.")
    ExitApp
}

; ===================================================================
; --- DATA STRUCTURES ---
; ===================================================================
TestScenarios := Map(
    "Global", Map(
        "Default", Map("base", Map("Z", 90, "C", 67), "shift", Map("Z", 90)),
        "Secondary", Map("base", Map("X", 88))
    ),
    "ahk_exe notepad.exe", Map(
        "Default", Map("shift", Map("C", 67))
    )
)

ActiveProfiles := Map(
    "Global", "Default",
    "ahk_exe notepad.exe", "Default"
)

; ===================================================================
; --- SCRIPT AUTO-EXECUTE SECTION ---
; ===================================================================
OnMessage(1325, MsgFunc)
SetTimer(MainContextLoop, 500)
MainContextLoop()

; ===================================================================
; --- CORE FUNCTIONS ---
; ===================================================================

SendData(Text) {
    socket := -1
    try {
        wsaData := Buffer(400)
        if (DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsaData.Ptr) != 0)
            throw Error("WSAStartup failed")
        
        socket := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")
        if (socket = -1 or socket = 0)
            throw Error("Socket creation failed")
        
        sockaddr := Buffer(16, 0)
        NumPut("UShort", 2, sockaddr, 0)
        NumPut("UShort", DllCall("ws2_32\htons", "UShort", 9001), sockaddr, 2)
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", "127.0.0.1"), sockaddr, 4)
        
        if (DllCall("ws2_32\connect", "UPtr", socket, "Ptr", sockaddr.Ptr, "Int", 16) != 0)
            throw Error("Connection failed")
        
        dataToSend := Text . "`n"
        requiredSize := StrPut(dataToSend, "UTF-8")
        dataBuffer := Buffer(requiredSize)
        StrPut(dataToSend, dataBuffer, "UTF-8")
        
        if (DllCall("ws2_32\send", "UPtr", socket, "Ptr", dataBuffer.Ptr, "Int", requiredSize - 1, "Int", 0) = -1)
            throw Error("Send failed")
    } catch as e {
        MsgBox("Network Error: " . e.Message)
    } finally {
        if (socket != -1 and socket != 0)
            DllCall("ws2_32\closesocket", "UPtr", socket)
        DllCall("ws2_32\WSACleanup")
    }
}

UpdateCatchList(vkCodeArray) {
    local vkCodesString := ""
    if (vkCodeArray.Length > 0) {
        for index, vk in vkCodeArray {
            vkCodesString .= vk . (index == vkCodeArray.Length ? "" : ",")
        }
    }
    local jsonData := '{"DeviceNumber": ' . MKB_DeviceNumber . ', "CatchVKCodes": "' . vkCodesString . '"}'
    SendData(jsonData)
    
    local activeContext := WinActive("ahk_exe notepad.exe") ? "ahk_exe notepad.exe"
        : "Global"

    ToolTip("Context: " . activeContext . "`nProfile: " . ActiveProfiles[activeContext] . "`nCatching: " . (vkCodesString != "" ? vkCodesString : "NONE"))
    SetTimer(() => ToolTip(), -2500)
}

MainContextLoop() {
    static lastContext := "", lastProfilesString := ""
    
    local currentContext := "Global"
    if (WinActive("ahk_exe notepad.exe")) {
        currentContext := "ahk_exe notepad.exe"
    }
    
    local currentProfilesString := ""
    for key, value in ActiveProfiles {
        currentProfilesString .= key . ":" . value . ","
    }

    if (currentContext == lastContext && currentProfilesString == lastProfilesString) {
        return
    }

    local catchList := Map()
    local activeMappingProfile := ActiveProfiles[currentContext]

    if (TestScenarios.Has(currentContext) && TestScenarios[currentContext].Has(activeMappingProfile)) {
        for layer, keyMap in TestScenarios[currentContext][activeMappingProfile] {
            for key, vk in keyMap {
                catchList[vk] := true
            }
        }
    }
    if (currentContext != "Global") {
        local activeGlobalMappingProfile := ActiveProfiles["Global"]
        if (TestScenarios["Global"].Has(activeGlobalMappingProfile)) {
            for layer, keyMap in TestScenarios["Global"][activeGlobalMappingProfile] {
                for key, vk in keyMap {
                    catchList[vk] := true
                }
            }
        }
    }
    
    local vkCodeArray := []
    ; MAJOR FIX: Replaced the non-existent `catchList.OwnKeys()` with the correct `for` loop.
    for vk, _ in catchList {
        vkCodeArray.Push(vk)
    }
    vkCodeArray.Push(9)

    UpdateCatchList(vkCodeArray)
    
    lastContext := currentContext
    lastProfilesString := currentProfilesString
}

ShowProfileToast(profileText) {
    ToastGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Profile Toast")
    ToastGui.BackColor := "E6E6E6"
    ToastGui.SetFont("s18 c1A1A1A", "Segoe UI")
    ToastGui.Add("Text", "w300 Center", profileText)
    ToastGui.Show("NoActivate")
    SetTimer(() => ToastGui.Destroy(), -2000)
}

; ===================================================================
; --- KEYPRESS HANDLER ---
; ===================================================================
MsgFunc(wParam, lParam, msg, hwnd) {
  OnUniqueKeyboard(wParam, lParam & 0xFF, (lParam & 0x100) > 0, (lParam & 0x1800) > 0, (lParam & 0x6000) > 0, (lParam & 0x8000) > 0)
}

OnUniqueKeyboard(KeyboardNumber, VKeyCode, IsDown, AnyCtrl, AnyAlt, Shift) {
    if (!IsDown || KeyboardNumber != MKB_DeviceNumber) {
        return
    }

    local currentContext := "Global"
  
    if (WinActive("ahk_exe notepad.exe")) {
        currentContext := "ahk_exe notepad.exe"
    }
    
    if (VKeyCode == 9) {
        local profileNames := [], activeMappingProfile := ActiveProfiles[currentContext]
        
        for name, _ in TestScenarios[currentContext] {
            profileNames.Push(name)
        }
        if (profileNames.Length == 0) {
            return
        }
        local currentIndex := 1
        for i, name in profileNames {
            if (name == activeMappingProfile) {
                currentIndex := i
                break
            }
        }
        local nextIndex := Mod(currentIndex, profileNames.Length) + 1
        ActiveProfiles[currentContext] := profileNames[nextIndex]
        ShowProfileToast(currentContext . " -> " . profileNames[nextIndex])
        MainContextLoop()
        return
    }

    local appHandled := false
    if (TestScenarios.Has(currentContext)) {
        local activeMappingProfile := ActiveProfiles[currentContext]
        
        if (currentContext == "ahk_exe notepad.exe") {
             if (Shift && !AnyCtrl && VKeyCode == 67) {
                MsgBox("Notepad > Default > Shift+C")
                appHandled := true
             }
        }
    }

    if (appHandled) {
        return
    }

    local activeGlobalMappingProfile := ActiveProfiles["Global"]
    if (activeGlobalMappingProfile == "Default") {
        if (!Shift && !AnyCtrl && VKeyCode == 90) {
            MsgBox("Global > Default > Z")
            appHandled := true
        }
        if (!Shift && !AnyCtrl && VKeyCode == 67) {
            MsgBox("Global > Default > C")
            appHandled := true
        }
        if (Shift && !AnyCtrl && VKeyCode == 90) {
            MsgBox("Global > Default > Shift+Z")
            appHandled := true
        }
    } else if (activeGlobalMappingProfile == "Secondary") {
        if (!Shift && !AnyCtrl && VKeyCode == 88) {
            MsgBox("Global > Secondary > X")
            appHandled := true
        }
    }
    
    if (appHandled) {
        return
    }
}