program MultiKB_For_AutoHotkey;

uses
  Vcl.Forms,
  Main in 'Main.pas' {FormMain},
  HookLibrary in 'src\HookLibrary.pas',
  KeyStroke in 'src\KeyStroke.pas',
  RawInput_API in 'src\RawInput_API.pas',
  VK_Codes in 'src\VK_Codes.pas',
  WindowsHook_Common in 'src\common\WindowsHook_Common.pas',
  Devices in 'src\Devices.pas',
  Configuration in 'src\Configuration.pas',
  ConfigureDevices_Wnd in 'ConfigureDevices_Wnd.pas' {FormConfigureDevices},
  Engine in 'src\Engine.pas',
  MemMap in 'src\common\MemMap.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormConfigureDevices, FormConfigureDevices);
  Application.Run;
end.
