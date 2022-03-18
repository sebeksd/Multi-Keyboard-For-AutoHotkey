object FormConfigureDevices: TFormConfigureDevices
  Left = 0
  Top = 0
  Caption = 'Manage devices'
  ClientHeight = 484
  ClientWidth = 755
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    755
    484)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelNewDevices: TLabel
    Left = 8
    Top = 8
    Width = 328
    Height = 13
    Caption = 
      'Recently connected devices (disconnect and connect to show here)' +
      ':'
  end
  object LabelConfiguredDevices: TLabel
    Left = 8
    Top = 253
    Width = 92
    Height = 13
    Caption = 'Configured devices'
  end
  object LabelName: TLabel
    Left = 8
    Top = 207
    Width = 62
    Height = 13
    Caption = 'Device Name'
  end
  object LabelNumber: TLabel
    Left = 135
    Top = 207
    Width = 58
    Height = 13
    Caption = 'Number (Id)'
  end
  object ListViewNewDevices: TListView
    Left = 8
    Top = 24
    Width = 739
    Height = 161
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        AutoSize = True
        Caption = 'System Id'
      end>
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListViewNewDevicesData
  end
  object ListViewConfiguredDevices: TListView
    Left = 8
    Top = 272
    Width = 739
    Height = 204
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Name'
        Width = 200
      end
      item
        Caption = 'Number'
      end
      item
        AutoSize = True
        Caption = 'System Id'
      end>
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnData = ListViewConfiguredDevicesData
  end
  object EditName: TEdit
    Left = 8
    Top = 226
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object SpinEditNumber: TSpinEdit
    Left = 135
    Top = 226
    Width = 66
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object ButtonAdd: TButton
    Left = 207
    Top = 224
    Width = 75
    Height = 25
    Caption = '\/'
    TabOrder = 4
    OnClick = ButtonAddClick
  end
  object ButtonRemove: TButton
    Left = 672
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Remove'
    TabOrder = 5
    OnClick = ButtonRemoveClick
  end
  object TimerRefreshNewDevices: TTimer
    Enabled = False
    OnTimer = TimerRefreshNewDevicesTimer
    Left = 64
    Top = 56
  end
end
