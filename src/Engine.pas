{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit Engine;

interface

uses
  Winapi.Messages, System.Classes, System.SyncObjs, KeyStroke, System.SysUtils,
  RawInput_API, Devices, Winapi.Windows, HookLibrary;

const
  WM_UNIQUE_KEYBOARD_EVENT = WM_USER + 301;
  cLogArrayLength = 50;
  cGarbageDelayMs = 10 * MSecsPerSec;

type
  TEngine = class(TThread)
    strict private
      fLock: TCriticalSection;
      fMainWindowHandle: THandle;
      fAutoHotkeyHandle: HWND;

      fHookLibrary: THookLibrary; // create Windows event hook

      fConnectedDevices: TDeviceList;
      fUserDevices: TDeviceList; //TODO

      fRawInputLog: array[0..cLogArrayLength-1] of TKeyLogItem;
      fRawInputFirstFreeIndex: Integer;

      procedure SetMainWindowHandle(const lHandle: THandle);
      procedure UpdateDevicesFromConfiguration();
      function RefreshConnectedDevices(): Boolean;

      procedure DetectAutoHotkey();

      procedure KeyStrokeToAutoHotkey(const lKeyStroke: TKeyStroke);

    private // unsafe, require Lock
      procedure ClearRawInputLog();
      procedure UpdateControlKeyStateForDevice(const lDevice: TDevice; const lKS: TKeyStroke);

    protected // unsafe, require Lock
      function FindRawInput(const lKS: TKeyStroke; const lSearchCount: Integer; out oIndex: Integer): Boolean;
      function FindDeviceInRawInputLog(var pKS: TKeyStroke): Boolean;

      function ProcessWaitingRawMessages: Integer;

      function GetDeviceByHandle(const lDeviceHandle: Integer): TDevice;

    protected
      procedure AddRawInput(const pRawdata: PRAWINPUT; const lDev: TDevice);
      procedure RemoveOldItems;

      procedure Execute(); override;

    public
      constructor Create();
      destructor Destroy; override;

      procedure Stop();

      procedure OnHookMessage(var Message: TMessage);
      procedure OnLLHookMessage(var Message: TMessage);
      procedure OnRawInmputMessage(var Message: TMessage);

      property MainWindowHandle: THandle write SetMainWindowHandle;
  end;

var
  gEngine: TEngine;

implementation

uses
  Configuration, System.Math, VK_Codes;

{ TEngine }

procedure TEngine.AddRawInput(const pRawdata: PRAWINPUT; const lDev: TDevice);
begin
  fLock.Enter;
  try
    fRawInputLog[fRawInputFirstFreeIndex].IsSet := True;
    fRawInputLog[fRawInputFirstFreeIndex].TimeStamp := GetTickCount64();
    fRawInputLog[fRawInputFirstFreeIndex].KeyStroke.DeviceHandle := pRawdata^.header.hDevice;
    fRawInputLog[fRawInputFirstFreeIndex].KeyStroke.VKeyCode := pRawdata^.keyboard.VKey;

    case pRawdata^.keyboard.Message of
      WM_KEYDOWN, WM_SYSKEYDOWN: fRawInputLog[fRawInputFirstFreeIndex].KeyStroke.Direction := kdDown;
      WM_KEYUP, WM_SYSKEYUP: fRawInputLog[fRawInputFirstFreeIndex].KeyStroke.Direction := kdUp;
    end;

    fRawInputLog[fRawInputFirstFreeIndex].KeyStroke.Device := lDev;

    fRawInputFirstFreeIndex := (fRawInputFirstFreeIndex + 1) mod cLogArrayLength;
  finally
    fLock.Leave;
  end;
end;

procedure TEngine.ClearRawInputLog;
begin
  fRawInputFirstFreeIndex := 0;
  ZeroMemory(@fRawInputLog[0], cLogArrayLength * SizeOf(TKeyLogItem));
end;

constructor TEngine.Create;
begin
  inherited Create(True);

  fHookLibrary := nil;

  fLock := TCriticalSection.Create;
  fMainWindowHandle := INVALID_HANDLE_VALUE;
  fAutoHotkeyHandle := 0;

  ClearRawInputLog();

  fUserDevices := TDeviceList.Create(TDeviceComparer.Create);
  fConnectedDevices := TDeviceList.Create(TDeviceComparer.Create);
end;

destructor TEngine.Destroy;
begin
  Terminate;
  WaitFor;

  FreeAndNil(fHookLibrary);
  FreeAndNil(fConnectedDevices);
  FreeAndNil(fUserDevices);
  FreeAndNil(fLock);
  inherited;
end;

procedure TEngine.DetectAutoHotkey;
var
  lHWND: HWND;
  lIsWindow: Boolean;
begin
  lHWND := FindWindow('AutoHotkey', nil);
  lIsWindow := IsWindow(lHWND);

  fLock.Enter;
  try
    if lIsWindow then
      fAutoHotkeyHandle := lHWND
    else
      fAutoHotkeyHandle := 0;
  finally
    fLock.Leave;
  end;
end;

procedure TEngine.Execute;
begin
  inherited;

  // load devices on start
  RefreshConnectedDevices();
  UpdateDevicesFromConfiguration();
  DetectAutoHotkey();

  while not Terminated do
  begin
    // check if user changed configuration, if yes then reload device list
    if RefreshConnectedDevices() or gConfiguration.IsChanged then
      UpdateDevicesFromConfiguration();

    // detect handle for AutoHotkey app
    DetectAutoHotkey();

    Sleep(1000);
  end;
end;

function TEngine.FindDeviceInRawInputLog(var pKS: TKeyStroke): Boolean;
var
  lNewItemsCount: Integer;
  lRawInputIndex: Integer;
begin
  // first search in log - already arrived raw messages
  if FindRawInput(pKS, cLogArrayLength, lRawInputIndex) then
  begin
    fRawInputLog[lRawInputIndex].IsSet := False;
    pKS.DeviceHandle := fRawInputLog[lRawInputIndex].KeyStroke.DeviceHandle;
  end;

  if (pKS.DeviceHandle > 0) then
  begin
    Result := True;
    Exit;
  end;

  // if not found, check main window message queue for incoming messages
  lNewItemsCount := gEngine.ProcessWaitingRawMessages;
  if (lNewItemsCount > 0) and FindRawInput(pKS, lNewItemsCount, lRawInputIndex) then
  begin
    fRawInputLog[lRawInputIndex].IsSet := False;
    pKS.DeviceHandle := fRawInputLog[lRawInputIndex].KeyStroke.DeviceHandle;
  end;

  if (pKS.DeviceHandle > 0) then
    Result := True
  else
    Result := False;
end;

function TEngine.FindRawInput(const lKS: TKeyStroke; const lSearchCount: Integer; out oIndex: Integer): Boolean;
var
  x: Integer;
begin
  // search log of received low level messages (with specific keyboard id)
  // and match it to received key via hook message (from active window)
  // add keybaord id into the param
  for x := 1 to lSearchCount do
  begin
    oIndex := (fRawInputFirstFreeIndex + cLogArrayLength - x) mod cLogArrayLength;
    if fRawInputLog[oIndex].IsSet then
    begin
      if fRawInputLog[oIndex].KeyStroke.IsEqual(lKS) then
      begin
        Result := True;
        Exit;
      end
    end
  end;

  oIndex := -1;
  Result := False;
end;

function TEngine.GetDeviceByHandle(const lDeviceHandle: Integer): TDevice;
var
  lItem: TDevice;
begin
  for lItem in fUserDevices do
  begin
    if (lDeviceHandle = lItem.Handle) then
    begin
      Result := lItem;
      Exit;
    end;
  end;

  Result := nil;
end;

procedure TEngine.KeyStrokeToAutoHotkey(const lKeyStroke: TKeyStroke);
var
  lWParam: WPARAM;
  lLParam: LPARAM;
begin
  // on 64 bit compilations WParam and LParam are 64 bit but we try to use only 32 bit part to be backward compatible
  if fAutoHotkeyHandle = 0 then
    Exit;

  lWParam := lKeyStroke.Device.Number; // this is used to identify device on AH side, its user defined, user can set same value for multiply devices
  lLParam := 0;

  lLParam := lLParam or (lKeyStroke.VKeyCode); // first 8 bit is VKeyCode // TODO split left/right Alt/Ctrl etc. to coresponding VKeyCodes?
  lLParam := lLParam or (IfThen(lKeyStroke.Direction = kdDown, 1, 0) shl 8); // bit 9 - direction/state Down = 1, Up = 0
  lLParam := lLParam or (IfThen(lKeyStroke.PreviousKeyState = kdDown, 1, 0) shl 9); // bit 10 - previous direction/state Down = 1, Up = 0
  lLParam := lLParam or (IfThen(lKeyStroke.IsExtendedKey, 1, 0) shl 10); // bit 11 - IsExtendedKey

  lLParam := lLParam or (IfThen(lKeyStroke.Device.State.LeftCtrl = kdDown, 1, 0) shl 11); // bit 12 - LeftCtrl
  lLParam := lLParam or (IfThen(lKeyStroke.Device.State.RightCtrl = kdDown, 1, 0) shl 12); // bit 13 - RightCtrl
  lLParam := lLParam or (IfThen(lKeyStroke.Device.State.LeftAlt = kdDown, 1, 0) shl 13); // bit 14 - LeftAlt
  lLParam := lLParam or (IfThen(lKeyStroke.Device.State.RightAlt = kdDown, 1, 0) shl 14); // bit 15 - RightAlt
  lLParam := lLParam or (IfThen(lKeyStroke.Device.State.Shift = kdDown, 1, 0) shl 15); // bit 16 - Shift

  PostMessage(fAutoHotkeyHandle, WM_UNIQUE_KEYBOARD_EVENT, lWParam, lLParam);
  //SendMessage(fMainWindowHandle, WM_UNIQUE_KEYBOARD_EVENT, lWParam, lLParam); // TODO REMOVE
end;

procedure TEngine.OnHookMessage(var Message: TMessage);
var
  lKS: TKeyStroke;
  lDoBlock: Boolean;
begin
  lDoBlock := False;

  // hook message has no device ID so we need RawInput for that
  fLock.Enter;
  try
    lKS := ConvertHookMessageToKeyStroke(Message.WParam, Message.LParam);

    if FindDeviceInRawInputLog(lKS) then
    begin
      lKS.Device := GetDeviceByHandle(lKS.DeviceHandle);

      if Assigned(lKS.Device) then
      begin
        // update current state of special control keys for this device
        UpdateControlKeyStateForDevice(lKS.Device, lKS);

        if lKS.IsOnCatchList() then
        begin
          // send keystroke to AutoHotkey
          KeyStrokeToAutoHotkey(lKS);

          lDoBlock := True;
        end;
      end;
    end;
  finally
    fLock.Leave;
  end;

  if lDoBlock then
    Message.Result := -1
  else
    Message.Result := 0;
end;

procedure TEngine.OnLLHookMessage(var Message: TMessage);
var
  lKS: TKeyStroke;
  lDoBlock: Boolean;
begin
  lDoBlock := False;

  // hook message has no device ID so we need RawInput for that
  fLock.Enter;
  try
    lKS := ConvertLLHookMessageToKeyStroke(Message.WParam, Message.LParam);

    if FindDeviceInRawInputLog(lKS) then
    begin
      lKS.Device := GetDeviceByHandle(lKS.DeviceHandle);

      if Assigned(lKS.Device) then
      begin
        // update current state of special control keys for this device
        UpdateControlKeyStateForDevice(lKS.Device, lKS);

        if lKS.IsOnCatchList() then
        begin
          // send keystroke to AutoHotkey
          KeyStrokeToAutoHotkey(lKS);

          lDoBlock := True;
        end;
      end;
    end;
  finally
    fLock.Leave;
  end;

  if lDoBlock then
    Message.Result := -1
  else
    Message.Result := 0;
end;

procedure TEngine.OnRawInmputMessage(var Message: TMessage);
var
  lRawInputSize: UINT;
  lRawInput: PRAWINPUT;
  lDev: TDevice;
begin
  GetRawInputData(Message.LParam, RID_INPUT, nil, lRawInputSize, sizeOf(RAWINPUTHEADER));

  GetMem(lRawInput, lRawInputSize);
  try
    if GetRawInputData(Message.LParam, RID_INPUT, lRawInput, lRawInputSize, sizeOf(RAWINPUTHEADER)) = lRawInputSize then
    begin
      if (lRawInput^.header.dwType <> RIM_TYPEKEYBOARD) then
        Exit;

      fLock.Enter;
      try
        // search device
        for lDev in fUserDevices do
        begin
          if (lDev.Handle = lRawInput^.header.hDevice) then
          begin
            AddRawInput(lRawInput, lDev);
            Break;
          end;
        end;
      finally
        fLock.Leave;
      end;
    end;
  finally
    FreeMem(lRawInput);
  end;

  Message.Result := 0;
end;

procedure TEngine.SetMainWindowHandle(const lHandle: THandle);
var
  ids: RAWINPUTDEVICE;
begin
  fLock.Enter;
  try
    fMainWindowHandle := lHandle;

    FreeAndNil(fHookLibrary); // if hook was created then destroy it

    if fMainWindowHandle = INVALID_HANDLE_VALUE then
      Exit;

    fHookLibrary := THookLibrary.Create(lHandle);
  finally
    fLock.Leave;
  end;

  ids.usUsagePage := 1;
  ids.usUsage := 6;  // keyboard
  ids.dwFlags := RIDEV_INPUTSINK; // + RIDEV_NOLEGACY;
  ids.hwndTarget := lHandle;
  if (not RegisterRawInputDevices(@ids, 1, SizeOf(ids))) then
  begin
    //Glb.LogError('Failed to register keyboard input messages.', cLoggerKbd);
  end;
end;

function TEngine.ProcessWaitingRawMessages: Integer;
var
  lMsg: TMSG;
  lMessage: TMessage;
begin
  Result := 0;
  if fMainWindowHandle = INVALID_HANDLE_VALUE then
    Exit;

  while PeekMessage(lMsg, fMainWindowHandle, WM_INPUT, WM_INPUT, PM_REMOVE) do
  begin
    lMessage.msg := lMsg.message;
    lMessage.wParam := lMsg.wParam;
    lMessage.lParam := lMsg.lParam;
    OnRawInmputMessage(lMessage);
    Inc(Result);
  end;
end;

function TEngine.RefreshConnectedDevices: Boolean;
var
  lPreviousDeviceCount: Integer;
begin
  // get all connected devices and raport if there was a change
  // this function can only by used by this thread
  lPreviousDeviceCount := fConnectedDevices.Count;
  DetectAllDevices(fConnectedDevices);

  Result := (lPreviousDeviceCount <> fConnectedDevices.Count);
end;

procedure TEngine.RemoveOldItems;
var
  x: Integer;
  lIndex: Integer;
  lNow: UInt64;
begin
  fLock.Enter;
  try
    lNow := GetTickCount64();
    for x := 1 to cLogArrayLength do
    begin
      lIndex := (fRawInputFirstFreeIndex + cLogArrayLength - x) mod cLogArrayLength;

      // unset unused items
      if (lNow - fRawInputLog[lIndex].TimeStamp > cGarbageDelayMs) then
        fRawInputLog[lIndex].IsSet := False;
    end;
  finally
    fLock.Leave;
  end;
end;

procedure TEngine.Stop;
begin
  Terminate;
  WaitFor;
end;

procedure TEngine.UpdateControlKeyStateForDevice(const lDevice: TDevice; const lKS: TKeyStroke);
begin
  if lKS.VKeyCode = VK_CONTROL then
  begin
    if lKS.IsExtendedKey then
      lDevice.State.RightCtrl := lKS.Direction
    else
      lDevice.State.LeftCtrl := lKS.Direction;
  end
  else if lKS.VKeyCode = VK_MENU then
  begin
    if lKS.IsExtendedKey then
      lDevice.State.RightAlt := lKS.Direction
    else
      lDevice.State.LeftAlt := lKS.Direction;
  end
  else if lKS.VKeyCode = VK_SHIFT then
  begin
    lDevice.State.Shift := lKS.Direction;
  end;
end;

procedure TEngine.UpdateDevicesFromConfiguration;
var
  lUserDeviceIndex: Integer;
  lConnectedDeviceIndex: Integer;
  lDevice: TDevice;
begin
  fLock.Enter;
  try
    fUserDevices.Clear;
    ClearRawInputLog(); // Raw input log has a pointer to Device so we need to clear it to

    // get only devices configured by user
    gConfiguration.CopyEnabledUserDevices(fUserDevices);

    // now we have list of devices configured (and enabled) by user, we need to fill handles for this devices
    for lUserDeviceIndex := fUserDevices.Count - 1 downto 0 do
    begin
      lDevice := fUserDevices[lUserDeviceIndex];
      lConnectedDeviceIndex := fConnectedDevices.IndexOf(lDevice);
      if lConnectedDeviceIndex <> -1 then
        lDevice.Handle := fConnectedDevices[lConnectedDeviceIndex].Handle
      else
        // device is configured by user but is not currently present in system, remove it for now
        fUserDevices.Delete(lUserDeviceIndex);
    end;
  finally
    fLock.Leave;
  end;
end;

initialization
  gEngine := TEngine.Create;

finalization
  FreeAndNil(gEngine);

end.
