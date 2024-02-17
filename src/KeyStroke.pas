{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit KeyStroke;

interface

uses
  Classes, SysUtils, Devices, Winapi.Windows, VK_Codes;

type
  TKeyStrokePtr = ^TKeyStroke;
  TKeyStroke = record
    Device: TDevice;
    DeviceHandle: Integer;

    VKeyCode: Byte;

    Direction: TKeyDirection;
    PreviousKeyState: TKeyDirection;
    AltState: TKeyDirection; // context code
    IsExtendedKey: Boolean;

    function IsEqual(const lKeyStroke: TKeyStroke): Boolean;
    function IsOnCatchList(): Boolean;
  end;

  TKeyLogItem = record
    IsSet: Boolean;
    TimeStamp: UInt64;
    KeyStroke: TKeyStroke;
  end;

  function ConvertHookMessageToKeyStroke(wParam: WPARAM; lParam: LPARAM): TKeyStroke;

implementation

function ConvertHookMessageToKeyStroke(wParam: WPARAM; lParam: LPARAM): TKeyStroke;
  function IsBitSet(const lValue, lIndex: NativeInt): Boolean;
  begin
    Result := lValue and (1 shl lIndex) <> 0;
  end;

begin
  Result.DeviceHandle := 0;  // unknown yet
  Result.Device := nil;  // unknown yet
  Result.VKeyCode := Byte(wParam);

//  if IsBitSet(lParam, 31) then
    Result.Direction := kdUp ;
//  else
//    Result.Direction := kdDown;

  if not IsBitSet(lParam, 30) then
    Result.PreviousKeyState := kdUp
  else
    Result.PreviousKeyState := kdDown;

  if not IsBitSet(lParam, 29) then
    Result.AltState := kdUp
  else
    Result.AltState := kdDown;

  if IsBitSet(lParam, 24) then
    Result.IsExtendedKey := True
  else
    Result.IsExtendedKey := False;
end;

{ TKeyStroke }

function TKeyStroke.IsEqual(const lKeyStroke: TKeyStroke): Boolean;
begin
  Result := (VKeyCode = lKeyStroke.VKeyCode) and (Direction = lKeyStroke.Direction);
end;

function TKeyStroke.IsOnCatchList: Boolean;
begin
  if not Assigned(Device) then
    Exit(False);

  Result := Device.CatchAll or Device.IsVKCodeOnCatchList(VKeyCode);
end;

end.


