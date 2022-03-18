{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  HookLibrary, WindowsHook_Common, Engine, Vcl.Menus;

type
  TFormMain = class(TForm)
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    PUMExit: TMenuItem;
    PUMConfig: TMenuItem;
    N1: TMenuItem;
    PUMAbout: TMenuItem;
    LabelProduct: TLabel;
    LabelVersion: TLabel;
    MemoInfo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure PUMExitClick(Sender: TObject);
    procedure PUMConfigClick(Sender: TObject);
    procedure PUMAboutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure OnWmInputMessage(var Message: TMessage); message WM_INPUT;
    procedure OnHookMessage(var Message: TMessage); message WM_HOOK_LIB_EVENT;

  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  VK_Codes, Devices, Configuration, ConfigureDevices_Wnd, StrUtils, KeyStroke;

{$R *.dfm}

function GetAppVersionStr: string;
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  // from https://delphihaven.wordpress.com/2012/12/08/retrieving-the-applications-version-string/
  Exe := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d',
    [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
     LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
     LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
     LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Hide;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  gEngine.MainWindowHandle := Self.Handle;

  LabelVersion.Caption := 'Version: ' + GetAppVersionStr;

  if Assigned(gEngine) then
    gEngine.Start;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  if Assigned(gEngine) then
    gEngine.Stop;
end;

procedure TFormMain.OnHookMessage(var Message: TMessage);
begin
  gEngine.OnHookMessage(Message);
end;

procedure TFormMain.OnWmInputMessage(var Message: TMessage);
begin
  gEngine.OnRawInmputMessage(Message);
end;

procedure TFormMain.PUMAboutClick(Sender: TObject);
begin
  Self.Show();
end;

procedure TFormMain.PUMConfigClick(Sender: TObject);
begin
  FormConfigureDevices.Show();
end;

procedure TFormMain.PUMExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormMain.TrayIconDblClick(Sender: TObject);
begin
  FormConfigureDevices.Show();
end;

end.
