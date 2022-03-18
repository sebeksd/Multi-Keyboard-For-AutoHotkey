{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit Devices;

interface

uses
  System.Generics.Defaults, System.Generics.Collections, System.Classes, VK_Codes;

type
  { TDevice }

  TDevice = class(TPersistent)
    private
      fEnabled: Boolean; // user provided information
      fName: string; // user provided information
      fNumber: Integer; // user provided information

      fSystemId: string; // unique for device and port
      fHandle: THandle; // unique "at this moment"

    public
      State: record
        LeftAlt: TKeyDirection;
        RightAlt: TKeyDirection;
        LeftCtrl: TKeyDirection;
        RightCtrl: TKeyDirection;
        Shift: TKeyDirection;
      end;

      constructor Create;

      function Clone: TDevice;
      procedure Assign(Source: TPersistent); override;

      procedure FillUserData(const lDevice: TDevice);

      function IsDeviceConfigured: Boolean;
      function IsDeviceEnabled: Boolean;
      function IsValid: Boolean;

      property Enabled: Boolean read fEnabled write fEnabled;
      property Name: string read fName write fName;
      property Number: Integer read fNumber write fNumber;

      property SystemId: string read fSystemId write fSystemId;
      property Handle: THandle read fHandle write fHandle;
  end;

  TDeviceList = TObjectList<TDevice>;

  TDeviceComparer = class(TComparer<TDevice>)
  public
    function Compare(const Left, Right: TDevice): Integer; override;
  end;

  function DetectAllDevices(var vDeviceList: TDeviceList): Integer;
  function DetectNewDevices(const lOldDeviceList: TDeviceList; var vDeviceList: TDeviceList): Integer;

  procedure FillDevicesWithUserData(const lDeviceList: TDeviceList; const lUserList: TDeviceList);
  procedure CopyEnabledUserDevices(const lDeviceList: TDeviceList; const lUserList: TDeviceList);

  function DeviceListToString(const lDeviceList: TDeviceList; const lEnabledOnly: Boolean = True): string;

implementation

uses
  RawInput_API, Winapi.Windows, System.SysUtils;

function DetectAllDevices(var vDeviceList: TDeviceList): Integer;
var
  deviceCount, StrLen, TmpSize: UINT;
  pDevicesHID: PRAWINPUTDEVICELIST;
  pDevice: PRAWINPUTDEVICELIST;
  pDeviceName: PChar;
  pDeviceInfo: PRID_DEVICE_INFO;
  x: Integer;

  lDetectedDevice: TDevice;
begin
  if not Assigned(vDeviceList) then
  begin
    Result := 0;
    Exit;
  end;

  vDeviceList.Clear;
  pDeviceInfo := nil;
  pDevicesHID := nil;
  deviceCount := 0;

  if (GetRawInputDeviceList(nil, deviceCount, sizeof(RAWINPUTDEVICELIST)) = 0) then
  begin
    try
      GetMem(pDevicesHID, deviceCount * sizeOf(RAWINPUTDEVICELIST));
      GetMem(pDeviceInfo, sizeOf(RID_DEVICE_INFO));
      pDevice := pDevicesHID;
      GetRawInputDeviceList(pDevicesHID, deviceCount, sizeof(RAWINPUTDEVICELIST));
      begin
        // process the list
        strLen := 0;
        for x := 0 to deviceCount - 1 do
        begin
          if (GetRawInputDeviceInfo(pDevice^.hDevice, RIDI_DEVICENAME, nil, StrLen) = 0) then
          begin
            pDeviceName := StrAlloc(StrLen);
            try
              GetRawInputDeviceInfo(pDevice^.hDevice, RIDI_DEVICENAME, pDeviceName, StrLen);
              TmpSize := sizeof(RID_DEVICE_INFO);
              pDeviceInfo^.cbSize := TmpSize;
              GetRawInputDeviceInfo(pDevice^.hDevice, RIDI_DEVICEINFO, pDeviceInfo, TmpSize);
              if (pDeviceInfo^.dwType = RIM_TYPEKEYBOARD) and (StrPos(StrUpper(pDeviceName), 'ROOT') = nil) then
              begin
                // add device to list
                lDetectedDevice := TDevice.Create;
                lDetectedDevice.SystemId := StrPas(pDeviceName);
                lDetectedDevice.Handle := pDevice^.hDevice;

                vDeviceList.Add(lDetectedDevice);
              end
            finally
              StrDispose(pDeviceName);
            end;
          end;
          Inc(pDevice);
        end;
      end;
    finally
      FreeMem(pDevicesHID);
      FreeMem(pDeviceInfo);
    end;
  end;

  Result := vDeviceList.Count;
end;

function DetectNewDevices(const lOldDeviceList: TDeviceList; var vDeviceList: TDeviceList): Integer;
var
  lTempDeviceList: TDeviceList;
  lTempDevice: TDevice;
begin
  if not Assigned(lOldDeviceList) or not Assigned(vDeviceList) then
  begin
    Result := 0;
    Exit;
  end;

  lTempDeviceList := TDeviceList.Create(False);
  try
    if DetectAllDevices(lTempDeviceList) > 0 then
    begin
      for lTempDevice in lTempDeviceList do
      begin
        if lOldDeviceList.IndexOf(lTempDevice) = -1 then
          vDeviceList.Add(lTempDevice) // put detected device as new
        else
          lTempDevice.Free; // known device, no longer needed
      end;
    end;
  finally
    lTempDeviceList.Free;
  end;

  Result := vDeviceList.Count;
end;

procedure FillDevicesWithUserData(const lDeviceList: TDeviceList; const lUserList: TDeviceList);
var
  lDevice: TDevice;
  lUserDeviceIndex: Integer;
begin
  // this procedure will fill current device list with data provided/configured by user such as name and Number
  for lDevice in lDeviceList do
  begin
    lUserDeviceIndex := lUserList.IndexOf(lDevice);
    if lUserDeviceIndex <> -1 then
      lDevice.FillUserData(lUserList[lUserDeviceIndex]);
  end;
end;

procedure CopyEnabledUserDevices(const lDeviceList: TDeviceList; const lUserList: TDeviceList);
var
  lDevice: TDevice;
begin
  // this procedure will copy only enabled user provided/configured devices
  for lDevice in lUserList do
  begin
    if lDevice.IsDeviceEnabled then
      lDeviceList.Add(lDevice.Clone);
  end;
end;

function DeviceListToString(const lDeviceList: TDeviceList; const lEnabledOnly: Boolean = True): string;
var
  lTempDevice: TDevice;
begin
  Result := '';

  for lTempDevice in lDeviceList do
  begin
    if (not lEnabledOnly) or lTempDevice.Enabled then
      Result := Result + '' + lTempDevice.Name + ' (' + IntToStr(lTempDevice.Number) + '): ' + lTempDevice.SystemId + sLineBreak;
  end;
end;

{ TDeviceComparer }

function TDeviceComparer.Compare(const Left, Right: TDevice): Integer;
begin
  Result := CompareText(Left.SystemId, Right.SystemId);
end;

{ TDevice }

procedure TDevice.Assign(Source: TPersistent);
var
  lDevice: TDevice;
begin
  if Source is TDevice then
  begin
    lDevice := TDevice(Source);

    fEnabled := lDevice.Enabled;
    fName := lDevice.Name;
    fNumber := lDevice.Number;
    fSystemId := lDevice.SystemId;
    fHandle := lDevice.Handle;
  end
  else
    inherited;
end;

function TDevice.Clone: TDevice;
begin
  Result := TDevice.Create;
  Result.Assign(Self);
end;

constructor TDevice.Create;
begin
  State.LeftAlt := kdUp;
  State.RightAlt := kdUp;
  State.LeftCtrl := kdUp;
  State.RightCtrl := kdUp;
  State.Shift:= kdUp;

  fHandle := INVALID_HANDLE_VALUE;
end;

procedure TDevice.FillUserData(const lDevice: TDevice);
begin
  // this data was provided by user
  fEnabled := lDevice.Enabled;
  fName := lDevice.Name;
  fNumber := lDevice.Number;
end;

function TDevice.IsDeviceConfigured: Boolean;
begin
  Result := ((Name <> '') and (Number > -1));
end;

function TDevice.IsDeviceEnabled: Boolean;
begin
  Result := (Enabled and IsDeviceConfigured());
end;

function TDevice.IsValid: Boolean;
begin
  Result := IsDeviceConfigured() and (SystemId <> '');
end;

end.
