object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Arcanum Dialog Debugger v1.50'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 447
    Width = 800
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 41
    ExplicitWidth = 445
  end
  object Label1: TLabel
    Left = 0
    Top = 41
    Width = 800
    Height = 13
    Align = alTop
    Caption = 'NPC Dialogue:'
    ExplicitWidth = 68
  end
  object Label2: TLabel
    Left = 0
    Top = 200
    Width = 800
    Height = 13
    Align = alTop
    Caption = 'Player Options:'
    ExplicitWidth = 74
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnLoadDLG: TButton
      Left = 8
      Top = 8
      Width = 100
      Height = 25
      Caption = 'Load .dlg'
      TabOrder = 0
      OnClick = btnLoadDLGClick
    end
    object btnOpenModule: TButton
      Left = 112
      Top = 8
      Width = 100
      Height = 25
      Caption = 'Module Manager'
      TabOrder = 1
      OnClick = btnOpenModuleClick
    end
    object btnStateWatch: TButton
      Left = 320
      Top = 8
      Width = 100
      Height = 25
      Caption = 'State Watch'
      TabOrder = 2
      OnClick = btnStateWatchClick
    end
    object btnPreferences: TButton
      Left = 428
      Top = 8
      Width = 100
      Height = 25
      Caption = 'Preferences...'
      TabOrder = 3
      OnClick = btnPreferencesClick
    end
  end
  object lbNPCLine: TListBox
    Left = 0
    Top = 54
    Width = 800
    Height = 146
    Align = alTop
    ItemHeight = 13
    TabOrder = 1
  end
  object lbPlayerOptions: TListBox
    Left = 0
    Top = 213
    Width = 800
    Height = 234
    Align = alClient
    ItemHeight = 13
    TabOrder = 2
    OnDblClick = lbPlayerOptionsDblClick
  end
  object pnlDebug: TPanel
    Left = 0
    Top = 450
    Width = 800
    Height = 150
    Align = alBottom
    Caption = 'pnlDebug'
    TabOrder = 3
    object mmoDebug: TMemo
      Left = 1
      Top = 1
      Width = 798
      Height = 148
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.dlg'
    Filter = 'Dialog Files (*.dlg)|*.dlg|All Files (*.*)|*.*'
    Left = 144
    Top = 8
  end
  object XPManifest1: TXPManifest
    Left = 616
    Top = 312
  end
end
