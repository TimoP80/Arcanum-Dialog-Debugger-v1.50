object frmModuleManager: TfrmModuleManager
  Left = 0
  Top = 0
  BorderStyle = bsSizeable
  Caption = 'Module Manager'
  ClientHeight = 400
  ClientWidth = 500
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlModules: TPanel
    Left = 8
    Top = 8
    Width = 484
    Height = 320
    BevelOuter = bvNone
    TabOrder = 0
    object lbModules: TListBox
      Left = 0
      Top = 0
      Width = 484
      Height = 320
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = lbModulesDblClick
    end
  end
  object btnLoadModule: TButton
    Left = 200
    Top = 340
    Width = 90
    Height = 25
    Caption = 'Load Module'
    TabOrder = 1
    OnClick = btnLoadModuleClick
  end
  object btnClose: TButton
    Left = 392
    Top = 340
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    OnClick = btnCloseClick
  end
end