{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}

unit ConfigureDevices_Wnd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,
  Devices;

type
  TFormConfigureDevices = class(TForm)
    ListViewNewDevices: TListView;
    ListViewConfiguredDevices: TListView;
    TimerRefreshNewDevices: TTimer;
    LabelNewDevices: TLabel;
    LabelConfiguredDevices: TLabel;
    EditName: TEdit;
    SpinEditNumber: TSpinEdit;
    ButtonAdd: TButton;
    ButtonRemove: TButton;
    LabelName: TLabel;
    LabelNumber: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TimerRefreshNewDevicesTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewNewDevicesData(Sender: TObject; Item: TListItem);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ListViewConfiguredDevicesData(Sender: TObject; Item: TListItem);
    procedure ButtonRemoveClick(Sender: TObject);
  private
    { Private declarations }
    fDeviceList: TDeviceList;
    fNewDeviceList: TDeviceList;
  public
    { Public declarations }
    procedure RefreshDevices();
  end;

var
  FormConfigureDevices: TFormConfigureDevices;

implementation

{$R *.dfm}

uses
  Math, Configuration;

procedure TFormConfigureDevices.ButtonAddClick(Sender: TObject);
var
  lDevice: TDevice;
begin
  if InRange(ListViewNewDevices.ItemIndex, 0, fNewDeviceList.Count - 1) then
  begin
    lDevice := fNewDeviceList[ListViewNewDevices.ItemIndex].Clone;

    lDevice.Enabled := True;
    lDevice.Name := EditName.Text;
    lDevice.Number := SpinEditNumber.Value;

    if fDeviceList.IndexOf(lDevice) = -1 then
    begin
      fDeviceList.Add(lDevice);

      // update configuration
      gConfiguration.UpdateDeviceList(fDeviceList, True);
    end;

    RefreshDevices();
  end;
end;

procedure TFormConfigureDevices.ButtonRemoveClick(Sender: TObject);
var
  lDevice: TDevice;
begin
  if InRange(ListViewConfiguredDevices.ItemIndex, 0, fDeviceList.Count - 1) then
  begin
    lDevice := fDeviceList[ListViewConfiguredDevices.ItemIndex];

    lDevice.Enabled := False;
    lDevice.Name := '';
    lDevice.Number := 0;

    // update configuration
    gConfiguration.UpdateDeviceList(fDeviceList, True);

    RefreshDevices();
  end;
end;

procedure TFormConfigureDevices.FormCreate(Sender: TObject);
begin
  fDeviceList := TDeviceList.Create(TDeviceComparer.Create);
  fNewDeviceList := TDeviceList.Create(TDeviceComparer.Create);
  DetectAllDevices(fDeviceList);

  gConfiguration.FillDevicesFromConfiguration(fDeviceList);

  RefreshDevices();
end;

procedure TFormConfigureDevices.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fNewDeviceList);
  FreeAndNil(fDeviceList);
end;

procedure TFormConfigureDevices.FormHide(Sender: TObject);
begin
  TimerRefreshNewDevices.Enabled := False;
end;

procedure TFormConfigureDevices.FormShow(Sender: TObject);
begin
  TimerRefreshNewDevices.Enabled := True;
end;

procedure TFormConfigureDevices.ListViewConfiguredDevicesData(Sender: TObject; Item: TListItem);
begin
  if InRange(Item.Index, 0, fDeviceList.Count - 1) then
  begin
    Item.Caption := fDeviceList[Item.Index].Name;
    Item.SubItems.Add(IntToStr(fDeviceList[Item.Index].Number));
    Item.SubItems.Add(fDeviceList[Item.Index].SystemId);
  end;
end;

procedure TFormConfigureDevices.ListViewNewDevicesData(Sender: TObject; Item: TListItem);
begin
  if InRange(Item.Index, 0, fNewDeviceList.Count - 1) then
  begin
    Item.Caption := fNewDeviceList[Item.Index].SystemId;
  end;
end;

procedure TFormConfigureDevices.RefreshDevices;
begin
  ListViewConfiguredDevices.Items.Count := fDeviceList.Count;
  ListViewConfiguredDevices.Refresh;
end;

procedure TFormConfigureDevices.TimerRefreshNewDevicesTimer(Sender: TObject);
var
  lTempDeviceList: TDeviceList;
  lDevice: TDevice;
begin
  // detect disconnections, update global list on disconnect
  lTempDeviceList := TDeviceList.Create();
  try
    if DetectAllDevices(lTempDeviceList) < fDeviceList.Count then
    begin
      lTempDeviceList.OwnsObjects := False;
      fDeviceList.Clear;

      for lDevice in lTempDeviceList do
        fDeviceList.Add(lDevice);
    end;
  finally
    lTempDeviceList.Free;
  end;

  // add devices that are not on main list to new list
  lTempDeviceList := TDeviceList.Create();
  try
    if DetectNewDevices(fDeviceList, lTempDeviceList) <> fNewDeviceList.Count then
    begin
      lTempDeviceList.OwnsObjects := False;
      fNewDeviceList.Clear;

      for lDevice in lTempDeviceList do
        fNewDeviceList.Add(lDevice);

      ListViewNewDevices.Items.Count := fNewDeviceList.Count;
      ListViewNewDevices.Refresh;
    end;
  finally
    lTempDeviceList.Free;
  end;
end;

end.
