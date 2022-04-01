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
    procedure ListViewConfiguredDevicesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListViewNewDevicesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure EditNameChange(Sender: TObject);
  private
    { Private declarations }
    fAllDeviceList: TDeviceList;
    fConfiguredDeviceList: TDeviceList;
    fNewDeviceList: TDeviceList;

    procedure RefreshButtons();
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
  if (ListViewConfiguredDevices.SelCount > 0) then
  begin
    // EDIT
    if InRange(ListViewConfiguredDevices.ItemIndex, 0, ListViewConfiguredDevices.Items.Count - 1) then
    begin
      lDevice := fConfiguredDeviceList[ListViewConfiguredDevices.ItemIndex];

      lDevice.Enabled := True;
      lDevice.Name := EditName.Text;
      lDevice.Number := SpinEditNumber.Value;

      gConfiguration.UpdateDeviceList(fConfiguredDeviceList, True);

      RefreshDevices();
    end;
  end
  else
  begin
    // ADD
    if InRange(ListViewNewDevices.ItemIndex, 0, fNewDeviceList.Count - 1) then
    begin
      lDevice := fNewDeviceList[ListViewNewDevices.ItemIndex].Clone;

      lDevice.Enabled := True;
      lDevice.Name := EditName.Text;
      lDevice.Number := SpinEditNumber.Value;

      if fConfiguredDeviceList.IndexOf(lDevice) = -1 then
      begin
        fConfiguredDeviceList.Add(lDevice);

        // update configuration
        gConfiguration.UpdateDeviceList(fConfiguredDeviceList, True);
      end;

      RefreshDevices();
    end;
  end;
end;

procedure TFormConfigureDevices.ButtonRemoveClick(Sender: TObject);
var
  lDevice: TDevice;
begin
  if InRange(ListViewConfiguredDevices.ItemIndex, 0, fConfiguredDeviceList.Count - 1) then
  begin
    lDevice := fConfiguredDeviceList[ListViewConfiguredDevices.ItemIndex];

    lDevice.Enabled := False;
    lDevice.Name := '';
    lDevice.Number := 0;

    // update configuration
    gConfiguration.UpdateDeviceList(fConfiguredDeviceList, True);

    RefreshDevices();
  end;
end;

procedure TFormConfigureDevices.EditNameChange(Sender: TObject);
begin
  RefreshButtons();
end;

procedure TFormConfigureDevices.FormCreate(Sender: TObject);
begin
  fAllDeviceList := TDeviceList.Create(TDeviceComparer.Create);
  fConfiguredDeviceList := TDeviceList.Create(TDeviceComparer.Create);
  fNewDeviceList := TDeviceList.Create(TDeviceComparer.Create);
  DetectAllDevices(fAllDeviceList);

  gConfiguration.CopyEnabledUserDevices(fConfiguredDeviceList);

  RefreshDevices();
  RefreshButtons();
end;

procedure TFormConfigureDevices.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fNewDeviceList);
  FreeAndNil(fConfiguredDeviceList);
  FreeAndNil(fAllDeviceList);
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
  if Assigned(Item) and InRange(Item.Index, 0, fConfiguredDeviceList.Count - 1) then
  begin
    Item.Caption := fConfiguredDeviceList[Item.Index].Name;
    Item.SubItems.Add(IntToStr(fConfiguredDeviceList[Item.Index].Number));
    Item.SubItems.Add(fConfiguredDeviceList[Item.Index].SystemId);
  end;
end;

procedure TFormConfigureDevices.ListViewConfiguredDevicesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    ListViewNewDevices.ClearSelection;
    if Assigned(Item) and InRange(Item.Index, 0, fConfiguredDeviceList.Count - 1) then
    begin
      EditName.Text := fConfiguredDeviceList[Item.Index].Name;
      SpinEditNumber.Value := fConfiguredDeviceList[Item.Index].Number;
    end;
    RefreshButtons();
  end;
end;

procedure TFormConfigureDevices.ListViewNewDevicesData(Sender: TObject; Item: TListItem);
begin
  if Assigned(Item) and InRange(Item.Index, 0, fNewDeviceList.Count - 1) then
  begin
    Item.Caption := fNewDeviceList[Item.Index].SystemId;
  end;
end;

procedure TFormConfigureDevices.ListViewNewDevicesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    ListViewConfiguredDevices.ClearSelection;
    EditName.Text := '';

    RefreshButtons();
  end;
end;

procedure TFormConfigureDevices.RefreshButtons;
begin
  ButtonAdd.Enabled := ((ListViewNewDevices.SelCount > 0) or (ListViewConfiguredDevices.SelCount > 0)) and (EditName.Text <> '');
  ButtonRemove.Enabled := (ListViewConfiguredDevices.SelCount > 0);

  if (ListViewNewDevices.SelCount > 0) then
  begin
    ButtonAdd.Caption := 'Add';
  end
  else if (ListViewConfiguredDevices.SelCount > 0) then
  begin
    ButtonAdd.Caption := 'Edit';
  end;
end;

procedure TFormConfigureDevices.RefreshDevices;
begin
  ListViewConfiguredDevices.Items.Count := fConfiguredDeviceList.Count;
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
    if DetectAllDevices(lTempDeviceList) < fAllDeviceList.Count then
    begin
      lTempDeviceList.OwnsObjects := False;
      fAllDeviceList.Clear;

      for lDevice in lTempDeviceList do
        fAllDeviceList.Add(lDevice);
    end;
  finally
    lTempDeviceList.Free;
  end;

  // add devices that are not on main list to new list
  lTempDeviceList := TDeviceList.Create();
  try
    if DetectNewDevices(fAllDeviceList, lTempDeviceList) <> fNewDeviceList.Count then
    begin
      lTempDeviceList.OwnsObjects := False;
      fNewDeviceList.Clear;

      for lDevice in lTempDeviceList do
      begin
        if fConfiguredDeviceList.IndexOf(lDevice) = -1 then
          fNewDeviceList.Add(lDevice);
      end;

      ListViewNewDevices.Items.Count := fNewDeviceList.Count;
      ListViewNewDevices.Refresh;
    end;
  finally
    lTempDeviceList.Free;
  end;
end;

end.
