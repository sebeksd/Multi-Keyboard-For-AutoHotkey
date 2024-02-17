{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit WindowsHook;

interface

uses
  Winapi.Windows, WindowsHook_Common, MemMap, Messages;

  function WindowsEventHook(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall; export;
  function LowLevelKeyboardProc(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall; export;

implementation

var
  gMemMap: TMemMap;
  gSharedPtr: PMMFData;

type
   TKBDLLHOOKSTRUCT = packed record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
   end;
   PTKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

//  DWORD     vkCode;
//  DWORD     scanCode;
//  DWORD     flags;
//  DWORD     time;
//  ULONG_PTR dwExtraInfo;
//} KBDLLHOOKSTRUCT, *LPKBDLLHOOKSTRUCT, *PKBDLLHOOKSTRUCT;

{
  The SetWindowsHookEx function installs an application-defined
  hook procedure into a hook chain.

  WH_GETMESSAGE Installs a hook procedure that monitors messages
  posted to a message queue.
  For more information, see the GetMsgProc hook procedure.
}

function WindowsEventHook(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall;
begin
  if (Code < 0) or (Code <> HC_ACTION) or (not Assigned(gSharedPtr)) then
    Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam)
  else
  begin
    if SendMessage(gSharedPtr^.MainWinHandle, WM_HOOK_LIB_EVENT, wParam, lParam) = -1 then
      Result := 1
    else
      Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam);
  end;
end;


function LowLevelKeyboardProc(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall;
begin
  if (Code < 0) or (Code <> HC_ACTION) or (not Assigned(gSharedPtr)) then
    Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam)
  else
  begin
    var lActionData: PTKBDLLHOOKSTRUCT;
    lActionData := PTKBDLLHOOKSTRUCT(lParam);

    var lVKCode: NativeUInt := lActionData.vkCode;
    var lFlags: NativeUInt := lActionData.flags;

    if SendMessage(gSharedPtr^.MainWinHandle, WM_HOOK_LIB_LL_EVENT, lVKCode, lFlags) = -1 then
      Result := 1
    else
      Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam);
  end;
end;

initialization
begin
  gSharedPtr := nil;
  gMemMap := nil;
  try
    gMemMap := TMemMap.Create(HOOK_MEMORY_NAME, SizeOf(TMMFData), True);
    gSharedPtr := gMemMap.Memory;
  except
    on EMemMapException do
    begin

    end;
  end;
end;

finalization
begin
  try
    gSharedPtr := nil;
    gMemMap.Free;
  except

  end;
end;

end.

