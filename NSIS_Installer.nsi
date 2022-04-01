
; This script is used to create Installer for Multi_Keyboard_For_AutoHotkey application

/*
   SaveGame Backup Tool -  Application for automatic Games Saves backup
   Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd
*/
;--------------------------------
!define PROGRAM_NAME "Multi_Keyboard_For_AutoHotkey"
!define DESCRIPTION "Application for extanding AutoHotkey with unique keybords detection"
!define COPYRIGHT "sebeksd (c) 2022"
!define INSTALLER_VERSION "1.0.0.0"

!define MAIN_APP_EXE "MultiKB_For_AutoHotkey.exe"
!define DESTINATION_PATH "Publish"
!define SOURCE_FILES_PATH "Publish\Files"

!define REG_ROOT "HKLM"
!define HKLM_REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall"

;--------------------------------
; The name of the installer
Name "${PROGRAM_NAME} Installer"

; Installer file info
!getdllversion "${SOURCE_FILES_PATH}\${MAIN_APP_EXE}" Expv_
VIProductVersion "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
VIAddVersionKey "ProductName"  "${PROGRAM_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${INSTALLER_VERSION}"

SetCompressor /SOLID LZMA
XPStyle on
Unicode True

; The file to write
OutFile "${DESTINATION_PATH}\Install_MultiKeyboardForAutoHotkey.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\${PROGRAM_NAME}"

; Request application privileges for Windows Vista
RequestExecutionLevel admin
;--------------------------------

; Pages
Page license
LicenseData "${SOURCE_FILES_PATH}\LICENSE"
	
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles
;--------------------------------

Section "Install"
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  # define uninstaller name
  WriteUninstaller $INSTDIR\uninstall.exe
  
  ; Put file there
  File "${SOURCE_FILES_PATH}\${MAIN_APP_EXE}"
  File "${SOURCE_FILES_PATH}\*.dll"
  File "${SOURCE_FILES_PATH}\*.md"
  File "${SOURCE_FILES_PATH}\LICENSE"
  File "${SOURCE_FILES_PATH}\*example*"
  
  ; Create start menu items
  CreateDirectory "$SMPROGRAMS\${PROGRAM_NAME}"
  CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\${PROGRAM_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
  
  ; Write the uninstall keys for Windows
  WriteRegStr ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "DisplayName" "${PROGRAM_NAME}"
  WriteRegStr ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "DisplayVersion" "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
  WriteRegStr ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "InstallLocation" '"$INSTDIR\"'
  WriteRegDWORD ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "NoModify" 1
  WriteRegDWORD ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "NoRepair" 1
SectionEnd ; end the section

Section "Uninstall"
  ; Remove registry keys
  DeleteRegKey ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}"
 
  # Always delete uninstaller first
  Delete $INSTDIR\uninstall.exe

  # delete installed file
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\*.md
  RMDir "$INSTDIR"
  
  # delete start menu items
  Delete "$SMPROGRAMS\${PROGRAM_NAME}\*.*"
  RMDir "$SMPROGRAMS\${PROGRAM_NAME}"
SectionEnd

# helper function to TrimQuotes
Function TrimQuotes
Exch $R0
Push $R1
 
  StrCpy $R1 $R0 1
  StrCmp $R1 `"` 0 +2
    StrCpy $R0 $R0 `` 1
  StrCpy $R1 $R0 1 -1
  StrCmp $R1 `"` 0 +2
    StrCpy $R0 $R0 -1
 
Pop $R1
Exch $R0
FunctionEnd
 
!macro _TrimQuotes Input Output
  Push `${Input}`
  Call TrimQuotes
  Pop ${Output}
!macroend
!define TrimQuotes `!insertmacro _TrimQuotes`

# check for path from previous installation (for update)
Function .onInit
 
  ReadRegStr $R0 ${REG_ROOT} "${HKLM_REG_UNINSTALL_PATH}\${PROGRAM_NAME}" "InstallLocation"
  
  StrCmp $R0 "" noUpdate
  
  ${TrimQuotes} $R0 $R0
  StrCpy $InstDir $R0
  
  noUpdate:
FunctionEnd
