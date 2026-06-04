object frmPreferences: TfrmPreferences
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 360
  ClientWidth = 520
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
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 312
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object grpPaths: TGroupBox
      Left = 8
      Top = 8
      Width = 504
      Height = 120
      Caption = 'Paths'
      TabOrder = 0
      object lblArcanumPath: TLabel
        Left = 12
        Top = 24
        Width = 110
        Height = 13
        Caption = 'Arcanum install path:'
        FocusControl = edtArcanumPath
      end
      object edtArcanumPath: TEdit
        Left = 12
        Top = 42
        Width = 410
        Height = 21
        TabOrder = 0
      end
      object btnBrowseArcanum: TButton
        Left = 428
        Top = 41
        Width = 64
        Height = 23
        Caption = 'Browse...'
        TabOrder = 1
        OnClick = btnBrowseArcanumClick
      end
      object lblLastDLGFolder: TLabel
        Left = 12
        Top = 72
        Width = 110
        Height = 13
        Caption = 'Last DLG folder:'
        FocusControl = edtLastDLGFolder
      end
      object edtLastDLGFolder: TEdit
        Left = 12
        Top = 90
        Width = 410
        Height = 21
        TabOrder = 2
      end
      object btnBrowseDLG: TButton
        Left = 428
        Top = 89
        Width = 64
        Height = 23
        Caption = 'Browse...'
        TabOrder = 3
        OnClick = btnBrowseDLGClick
      end
    end
    object grpOptions: TGroupBox
      Left = 8
      Top = 136
      Width = 504
      Height = 160
      Caption = 'Options'
      TabOrder = 1
      object chkVerboseDebug: TCheckBox
        Left = 12
        Top = 24
        Width = 480
        Height = 17
        Caption = 'Verbose debug output'
        TabOrder = 0
      end
      object chkDebugLogging: TCheckBox
        Left = 12
        Top = 48
        Width = 480
        Height = 17
        Caption = 'Enable debug logging in main window'
        TabOrder = 1
      end
      object lblLineNumberStep: TLabel
        Left = 12
        Top = 80
        Width = 180
        Height = 13
        Caption = 'Dialog line number step:'
        FocusControl = edtLineNumberStep
      end
      object edtLineNumberStep: TSpinEdit
        Left = 12
        Top = 98
        Width = 80
        Height = 22
        MaxLength = 4
        TabOrder = 2
        Value = 20
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 312
    Width = 520
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 248
      Top = 12
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 328
      Top = 12
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnApply: TButton
      Left = 408
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = btnApplyClick
    end
  end
end
