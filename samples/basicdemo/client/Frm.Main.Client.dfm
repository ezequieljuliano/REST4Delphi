object FrmMainClient: TFrmMainClient
  Left = 0
  Top = 0
  Caption = 'Basic Demo Client'
  ClientHeight = 379
  ClientWidth = 871
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
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
    Top = 104
    Width = 871
    Height = 275
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
  object Button4: TButton
    Left = 32
    Top = 55
    Width = 75
    Height = 25
    Caption = 'Post User'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 113
    Top = 55
    Width = 75
    Height = 25
    Caption = 'Post Users'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 194
    Top = 55
    Width = 135
    Height = 25
    Caption = 'Get User (Unauthorized)'
    TabOrder = 6
    OnClick = Button6Click
  end
end
