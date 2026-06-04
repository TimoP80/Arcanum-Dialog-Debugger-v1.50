object frmStateWatch: TfrmStateWatch
  Left = 0
  Top = 0
  Caption = 'State Watch'
  ClientHeight = 480
  ClientWidth = 640
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
  object pcState: TPageControl
    Left = 8
    Top = 8
    Width = 624
    Height = 400
    ActivePage = tsFlagsVars
    TabOrder = 0
    object tsFlagsVars: TTabSheet
      Caption = 'Flags / Vars'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gvFlags: TStringGrid
        Left = 8
        Top = 8
        Width = 296
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 0
        ColWidths = (
          80
          192)
      end
      object gvVars: TStringGrid
        Left = 312
        Top = 8
        Width = 296
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 1
        ColWidths = (
          80
          192)
      end
    end
    object tsState: TTabSheet
      Caption = 'State'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gvState: TStringGrid
        Left = 8
        Top = 8
        Width = 600
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 0
        ColWidths = (
          152
          432)
      end
    end
    object tsSkills: TTabSheet
      Caption = 'Skills'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gvSkills: TStringGrid
        Left = 8
        Top = 8
        Width = 600
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 0
        ColWidths = (
          200
          384)
      end
    end
    object tsQuests: TTabSheet
      Caption = 'Quests'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gvQuests: TStringGrid
        Left = 8
        Top = 8
        Width = 600
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 0
        ColWidths = (
          120
          464)
      end
    end
    object tsRumors: TTabSheet
      Caption = 'Rumors'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gvRumors: TStringGrid
        Left = 8
        Top = 8
        Width = 600
        Height = 352
        ColCount = 2
        FixedCols = 0
        RowCount = 2
        TabOrder = 0
        ColWidths = (
          120
          464)
      end
    end
  end
  object btnRefresh: TButton
    Left = 480
    Top = 420
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 1
    OnClick = btnRefreshClick
  end
  object btnClose: TButton
    Left = 568
    Top = 420
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    OnClick = btnCloseClick
  end
end
