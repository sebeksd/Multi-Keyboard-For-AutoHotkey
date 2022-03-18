{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit HookLibrary;

interface

uses
  Classes, SysUtils, Windows, KeyStroke, Winapi.Messages,
  System.SyncObjs, MemMap, WindowsHook_Common;

type
  { THookLibrary }

  THookLibrary = class
    strict private
      fDllHandle: HINST;

      fSharedMemory: TMemMap;
      fSMPtr: PMMFData;

      function SetHook(): Boolean;
      function FreeHook(): Boolean;

      procedure InitSharedMemory(const lMainFormHandle: THandle);
    public
      constructor Create(const lMainWindowHandle: THandle); reintroduce;
      destructor Destroy; override;
  end;

implementation

uses
  VK_Codes, Main;

const
  HookLib = 'WinHook.dll';

{ THookLibrary }

function THookLibrary.SetHook: Boolean;
begin
  Result := False;
  if not Assigned(fSMPtr) then
    Exit;

  fDllHandle := LoadLibrary(HookLib);
  if fDllHandle <> INVALID_HANDLE_VALUE then
  begin
    fSMPtr^.HookKbd := SetWindowsHookEx(WH_KEYBOARD, GetProcAddress(fDllHandle, 'WindowsEventHook'), fDllHandle, 0);
    if (fSMPtr^.HookKbd = 0) then
      FreeHook  // free is something was not ok
    else
      Result := True;
  end;
end;

function THookLibrary.FreeHook: Boolean;
begin
  Result := True;
  if Assigned(fSMPtr) and (fSMPtr^.HookKbd <> 0) then
  begin
    Result := UnHookWindowsHookEx(fSMPtr^.HookKbd);
    fSMPtr^.HookKbd := 0;
  end;

  if (fDllHandle <> INVALID_HANDLE_VALUE) then
    FreeLibrary(fDllHandle);
end;

procedure THookLibrary.InitSharedMemory(const lMainFormHandle: THandle);
begin
  fSMPtr := nil;
  try
    fSharedMemory := TMemMap.Create(HOOK_MEMORY_NAME, SizeOf(TMMFData), True);
    fSMPtr := fSharedMemory.Memory;
  except
    on EMemMapException do
    begin
      fSharedMemory := nil;
    end;
  end;
  if Assigned(fSMPtr) then
  begin
    fSMPtr^.MainWinHandle := lMainFormHandle;
    fSMPtr^.LmcPID := GetCurrentProcessId;
    fSMPtr^.Debug := 0; // for now
  end;
end;

constructor THookLibrary.Create(const lMainWindowHandle: THandle);
begin
  inherited Create();
  fDllHandle := INVALID_HANDLE_VALUE;
  fSMPtr := nil;
  InitSharedMemory(lMainWindowHandle);
  SetHook();
end;

destructor THookLibrary.Destroy;
begin
  FreeHook();
  fSMPtr := nil;
  FreeAndNil(fSharedMemory);
  inherited;
end;

end.

