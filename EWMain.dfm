object FormWindows: TFormWindows
  Left = 0
  Top = 0
  Caption = 'FormWindows'
  ClientHeight = 708
  ClientWidth = 928
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = pmAll
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    928
    708)
  PixelsPerInch = 96
  TextHeight = 13
  object laClassName: TLabel
    Left = 32
    Top = 640
    Width = 60
    Height = 13
    Caption = 'laClassName'
  end
  object laMsg: TLabel
    Left = 524
    Top = 248
    Width = 27
    Height = 13
    Caption = 'laMsg'
    WordWrap = True
  end
  object laPClassName: TLabel
    Left = 32
    Top = 690
    Width = 66
    Height = 13
    Caption = 'laPClassName'
  end
  object laPWndTitle: TLabel
    Left = 32
    Top = 662
    Width = 56
    Height = 13
    Caption = 'laPWndTitle'
  end
  object laWndTitle: TLabel
    Left = 32
    Top = 608
    Width = 50
    Height = 13
    Caption = 'laWndTitle'
  end
  object laFindTxt: TLabel
    Left = 431
    Top = 545
    Width = 50
    Height = 13
    Caption = 'laWndTitle'
  end
  object BtnBuild: TButton
    Left = 393
    Top = 8
    Width = 81
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1055#1086#1089#1090#1088#1086#1080#1090#1100
    TabOrder = 0
    OnClick = BtnBuildClick
  end
  object buSSMS: TButton
    Left = 518
    Top = 166
    Width = 75
    Height = 65
    Caption = 'buSSMS'
    TabOrder = 1
    OnClick = buSSMSClick
  end
  object edApp: TEdit
    Left = 112
    Top = 582
    Width = 369
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Text = 'edApp'
  end
  object edMax: TEdit
    Left = 522
    Top = 106
    Width = 78
    Height = 21
    TabOrder = 5
    Text = 'edMax'
  end
  object edPWndTitle: TEdit
    Left = 112
    Top = 659
    Width = 369
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 7
    Text = 'edPWndTitle'
  end
  object edWndTitle: TEdit
    Left = 112
    Top = 605
    Width = 369
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 8
    Text = 'edWndTitle'
  end
  object TreeWindows: TTreeView
    Left = 8
    Top = 8
    Width = 378
    Height = 567
    Anchors = [akLeft, akTop, akRight, akBottom]
    Indent = 19
    PopupMenu = pmAll
    TabOrder = 9
    OnClick = TreeWindowsClick
  end
  object chkAutoClose: TCheckBox
    Left = 445
    Top = 363
    Width = 97
    Height = 17
    Caption = #1057#1088#1072#1079#1091' '#1079#1072#1082#1088#1099#1090#1100
    TabOrder = 2
  end
  object edClassName: TComboBox
    Left = 112
    Top = 632
    Width = 369
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    Text = 'edClassName'
  end
  object edPClassName: TComboBox
    Left = 112
    Top = 686
    Width = 369
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 6
    Text = 'edPClassName'
  end
  object edFindTxt: TEdit
    Left = 518
    Top = 542
    Width = 249
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 10
    Text = 'edFindTxt'
  end
  object pmAll: TPopupMenu
    Left = 560
    Top = 400
    object NFind: TMenuItem
      Caption = #1055#1086#1080#1089#1082
      OnClick = NFindClick
    end
  end
end
