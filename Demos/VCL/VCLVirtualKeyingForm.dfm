object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'VCL Virtual Key Press Demo'
  ClientHeight = 122
  ClientWidth = 258
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 15
  object lblCharsToType: TLabel
    Left = 8
    Top = 8
    Width = 99
    Height = 15
    Caption = 'Characters to type:'
  end
  object edtCharsToType: TEdit
    Left = 8
    Top = 29
    Width = 241
    Height = 23
    TabOrder = 0
    Text = #161'Hola! '#915#949#953#940'! '#1055#1088#1080#1074#1077#1090'!'
  end
  object btnTypeInEdit: TButton
    Left = 8
    Top = 58
    Width = 113
    Height = 25
    Caption = 'Type in Edit Box'
    TabOrder = 1
    OnClick = btnTypeInEditClick
  end
  object btnTypeIn10Secs: TButton
    Left = 127
    Top = 58
    Width = 122
    Height = 25
    Caption = 'Type in 10 Seconds'
    TabOrder = 2
    OnClick = btnTypeIn10SecsClick
  end
  object edtTarget: TEdit
    Left = 8
    Top = 89
    Width = 113
    Height = 23
    TabOrder = 3
  end
  object btnDoAppExitHotkey: TButton
    Left = 127
    Top = 89
    Width = 122
    Height = 25
    Caption = 'Exit with Alt+F4'
    TabOrder = 4
    OnClick = btnDoAppExitHotkeyClick
  end
  object tmrType: TTimer
    Enabled = False
    OnTimer = tmrTypeTimer
    Left = 208
    Top = 8
  end
end
