object MainClientAdapter: TMainClientAdapter
  Left = 0
  Top = 0
  Caption = 'Basic Demo Client Adapter'
  ClientHeight = 388
  ClientWidth = 798
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 32
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Get User'
    TabOrder = 0
    OnClick = Button1Click
  end
  object MemResp: TMemo
    Left = 0
    Top = 70
    Width = 798
    Height = 318
    Align = alBottom
    TabOrder = 1
  end
  object Button2: TButton
    Left = 113
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Get Users'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 194
    Top = 24
    Width = 135
    Height = 25
    Caption = 'Hello World'
    TabOrder = 3
    OnClick = Button3Click
  end
end
