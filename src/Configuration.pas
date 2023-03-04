{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit Configuration;

interface

uses
  System.SyncObjs, Devices, System.IniFiles, System.Generics.Collections;

const
  gcConfigurationDir = 'MultiKeyboardForAutoHotkey\';
  gcConfigurationPath = gcConfigurationDir + 'Configuration.ini';

type
  TConfiguration = class
    strict private
      fLock: TCriticalSection;
      fConfigurationDirPath: string;
      fConfigurationFullPath: string;

      // internal use only, not in file
      fIsChanged: Boolean;

      // in configuration file
      fStartOnAppLaunch: Boolean;
      fConfiguredDeviceList: TDeviceList;

      procedure SetDefaults;
      function GetIsChanged: Boolean;

      procedure VKCodesStringListToList(const pList: TList<Integer>; const lVKCodesStr: string);
      function ListToVKCodesStringList(const lList: TList<Integer>): string;

    protected // unsafe, require Lock
      function Load(const lPath: string): Boolean;
      function Save(const lPath: string): Boolean;

    public
      constructor Create();
      destructor Destroy; override;

      procedure UpdateDeviceList(const lDeviceList: TDeviceList; const lSave: Boolean);
      procedure FillDevicesFromConfiguration(const lDeviceList: TDeviceList);
      procedure CopyEnabledUserDevices(const lDeviceList: TDeviceList);

      property IsChanged: Boolean read GetIsChanged;
  end;

var
  gConfiguration: TConfiguration;

implementation

uses
  System.SysUtils, Winapi.Windows, SHFolder, Vcl.Dialogs, Classes;

function GetAppDataLocalPath: string;
var
  Path: array[0..MAX_PATH] of Char;
begin
  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, Path) = S_OK then
    Result := IncludeTrailingPathDelimiter(Path)
  else
    Result := '';
end;

{ TConfiguration }

procedure TConfiguration.CopyEnabledUserDevices(const lDeviceList: TDeviceList);
begin
  fLock.Enter;
  try
    Devices.CopyEnabledUserDevices(lDeviceList, fConfiguredDeviceList);

    fIsChanged := False;
  finally
    fLock.Leave;
  end;
end;

constructor TConfiguration.Create;
begin
  inherited;

  fIsChanged := False;

  fLock := TCriticalSection.Create;
  fConfiguredDeviceList := TDeviceList.Create(TDeviceComparer.Create);

  // get AppData\Local\ + own dir patch
  fConfigurationDirPath := GetAppDataLocalPath();
  fConfigurationFullPath := fConfigurationDirPath + gcConfigurationPath;

  if not Load(fConfigurationFullPath) then
    SetDefaults();
end;

destructor TConfiguration.Destroy;
begin
  Save(fConfigurationFullPath);
  FreeAndNil(fConfiguredDeviceList);
  FreeAndNil(fLock);

  inherited;
end;

procedure TConfiguration.FillDevicesFromConfiguration(const lDeviceList: TDeviceList);
begin
  fLock.Enter;
  try
    Devices.FillDevicesWithUserData(lDeviceList, fConfiguredDeviceList);
  finally
    fLock.Leave;
  end;
end;

function TConfiguration.GetIsChanged: Boolean;
begin
  fLock.Enter;
  try
    Result := fIsChanged;
  finally
    fLock.Leave;
  end;
end;

function TConfiguration.ListToVKCodesStringList(const lList: TList<Integer>): string;
begin
  Result := '';
  for var x: Integer := 0 to lList.Count - 1 do
  begin
    if x > 0 then
      Result := Result + ',';

    Result := Result + IntToStr(lList[x]);
  end;
end;

function TConfiguration.Load(const lPath: string): Boolean;
var
  lInitFile: TIniFile;
  lDeviceCount: Integer;
  x: Integer;
  lSectionName: string;
  lDevice: TDevice;
begin
 try
    lInitFile := TIniFile.Create(lPath);
    fLock.Enter;
    try
      // general section
      fStartOnAppLaunch := lInitFile.ReadBool('General', 'StartOnAppLaunch', True);
      lDeviceCount := lInitFile.ReadInteger('General', 'DeviceCount', 0);

      // devices section
      for x := 0 to lDeviceCount - 1 do
      begin
        lSectionName := 'Device' + IntToStr(x+1);

        lDevice := TDevice.Create;
        lDevice.Enabled := lInitFile.ReadBool(lSectionName, 'Enabled', False);
        lDevice.Name := lInitFile.ReadString(lSectionName, 'Name', '');
        lDevice.Number := lInitFile.ReadInteger(lSectionName, 'Number', -1);
        lDevice.SystemId := lInitFile.ReadString(lSectionName, 'SystemId', '');

        lDevice.CatchAll := lInitFile.ReadBool(lSectionName, 'CatchAll', True);
        if not lDevice.CatchAll then
        begin
          var lCatchListStr: string := lInitFile.ReadString(lSectionName, 'CatchVKCodes', '');
          VKCodesStringListToList(lDevice.CatchList, lCatchListStr);
        end;

        // validate before add
        if not lDevice.IsValid() then
          lDevice.Free
        else
          fConfiguredDeviceList.Add(lDevice);
      end;

      fIsChanged := False;
    finally
      fLock.Leave;
      lInitFile.Free;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

function TConfiguration.Save(const lPath: string): Boolean;
var
  lInitFile: TIniFile;
  lDir: string;

  x: Integer;
  lSectionName: string;
begin
  // writing is done to temp file for two reasons
  // 1. it safer, during power loss (or something similar) file could get demeged during write, it is less likley to be demaged during rename
  // 2. we want to do cleanup remove old devices that have no user info or other values that are not used anymore (not loading old file)
  lDir := ExtractFileDir(lPath);
  if not DirectoryExists(lDir) then
    ForceDirectories(lDir)
  else
    System.SysUtils.DeleteFile(lPath + '.tmp'); // if temp file already exists, remove it

  try
    lInitFile := TIniFile.Create(lPath + '.tmp');
    fLock.Enter;
    try
      // general section
      lInitFile.WriteBool('General', 'StartOnAppLaunch', fStartOnAppLaunch);
      lInitFile.WriteInteger('General', 'DeviceCount', fConfiguredDeviceList.Count);

      // devices section
      for x := 0 to fConfiguredDeviceList.Count - 1 do
      begin
        lSectionName := 'Device' + IntToStr(x+1);

        lInitFile.WriteBool(lSectionName, 'Enabled', fConfiguredDeviceList[x].Enabled);
        lInitFile.WriteString(lSectionName, 'Name', fConfiguredDeviceList[x].Name);
        lInitFile.WriteInteger(lSectionName, 'Number', fConfiguredDeviceList[x].Number);
        lInitFile.WriteString(lSectionName, 'SystemId', fConfiguredDeviceList[x].SystemId);

        lInitFile.WriteBool(lSectionName, 'CatchAll', fConfiguredDeviceList[x].CatchAll);
        lInitFile.WriteString(lSectionName, 'CatchVKCodes', ListToVKCodesStringList(fConfiguredDeviceList[x].CatchList));
      end;
      lInitFile.UpdateFile;
    finally
      fLock.Leave;
      lInitFile.Free;
    end;

    // Delete old config file and replace it with new one
    System.SysUtils.DeleteFile(lPath);
    Result := System.SysUtils.RenameFile(lPath + '.tmp', lPath);
  except
    Result := False;
  end;
end;

procedure TConfiguration.SetDefaults;
begin
  fStartOnAppLaunch := True;
end;

procedure TConfiguration.UpdateDeviceList(const lDeviceList: TDeviceList; const lSave: Boolean);
var
  lDevice: TDevice;
begin
  if not Assigned(lDeviceList) then
   Exit;

  fLock.Enter;
  try
    fIsChanged := True;
    fConfiguredDeviceList.Clear;
    for lDevice in lDeviceList do
    begin
      // remember only devices that have user info
      if lDevice.IsDeviceConfigured() then
        fConfiguredDeviceList.Add(lDevice.Clone);
    end;

    if lSave then
      Save(fConfigurationFullPath);
  finally
    fLock.Leave;
  end;
end;

procedure TConfiguration.VKCodesStringListToList(const pList: TList<Integer>; const lVKCodesStr: string);
begin
  if lVKCodesStr = '' then
  begin
    pList.Clear;
    Exit;
  end;

  var lStringList: TStringList := TStringList.Create;
  try
    lStringList.StrictDelimiter := True;
    lStringList.Delimiter := ',';
    lStringList.DelimitedText := lVKCodesStr;

    for var x: Integer := 0 to lStringList.Count - 1 do
    begin
      var lVKCode: Integer := StrToIntDef(Trim(lStringList[x]), -1);
      if (lVKCode > -1) then
        pList.Add(lVKCode);
    end;
  finally
    FreeAndNil(lStringList);
  end;
end;

initialization
  gConfiguration := TConfiguration.Create;

finalization
  FreeAndNil(gConfiguration);

end.
