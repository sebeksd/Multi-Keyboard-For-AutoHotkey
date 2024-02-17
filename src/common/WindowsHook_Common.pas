{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit WindowsHook_Common;

interface

uses
  Windows, Winapi.Messages;

const
  WM_HOOK_LIB_EVENT = WM_USER + 300;
  WM_HOOK_LIB_LL_EVENT = WM_USER + 301;
  HOOK_MEMORY_NAME = 'MKFAH_SharedMem';

type
  PMMFData = ^TMMFData;
  TMMFData = record
    MainWinHandle: HWND;
    LmcPID: DWORD;
    Debug: DWORD;  // 0 = no debug
    HookKbd: HHOOK;
  end;

  // hook function called from OS
  TWindowsHook = function(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall;

  // output callback to push hooks back to app
  THookCallback = function(wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

  THookLibraryInit = function (const lCallback: THookCallback; const lEventToHook: Integer; const lMainFormHandle: THandle): HHOOK; stdcall;

implementation

end.

