object AudioFormatDlg: TAudioFormatDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Select Audio Format'
  ClientHeight = 507
  ClientWidth = 428
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 428
    Height = 474
    Align = alTop
    Shape = bsFrame
    ExplicitLeft = 1
    ExplicitTop = 1
  end
  object lblAudioFmt: TLabel
    Left = 8
    Top = 4
    Width = 406
    Height = 64
    AutoSize = False
    Caption = 'Audiofmt'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label1: TLabel
    Left = 11
    Top = 378
    Width = 47
    Height = 13
    Caption = 'Extra info'
  end
  object butOk: TButton
    Left = 261
    Top = 477
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = butOkClick
  end
  object butCancel: TButton
    Left = 339
    Top = 477
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = butCancelClick
  end
  object butSaveToFile: TButton
    Left = 8
    Top = 477
    Width = 83
    Height = 25
    Hint = 'Save formats to file (AudioProfiles.txt)'
    Caption = 'Save Formats'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = butSaveToFileClick
  end
  object stxtBitRate: TStaticText
    Left = 11
    Top = 74
    Width = 102
    Height = 20
    Alignment = taCenter
    AutoSize = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = sbsSunken
    Caption = 'Bit Rate (kbps)'
    Color = clMenuHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 3
    Transparent = False
    OnClick = stxtBitRateClick
  end
  object stxtSampleRate: TStaticText
    Left = 113
    Top = 74
    Width = 102
    Height = 20
    Alignment = taCenter
    AutoSize = False
    BorderStyle = sbsSunken
    Caption = 'Sampling Rate (Khz)'
    Color = clMenuHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 4
    Transparent = False
    OnClick = stxtSampleRateClick
  end
  object stxtChannels: TStaticText
    Left = 314
    Top = 74
    Width = 102
    Height = 20
    Alignment = taCenter
    AutoSize = False
    BorderStyle = sbsSunken
    Caption = 'Channels'
    Color = clMenuHighlight
    ParentColor = False
    TabOrder = 5
    Transparent = False
    OnClick = stxtChannelsClick
  end
  object sgAudioEncoderFormats: TStringGrid
    Left = 11
    Top = 95
    Width = 405
    Height = 280
    DefaultColWidth = 100
    FixedCols = 0
    RowCount = 2
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 6
    OnClick = sgAudioEncoderFormatsClick
  end
  object stxtBitsPerSample: TStaticText
    Left = 215
    Top = 74
    Width = 102
    Height = 20
    Alignment = taCenter
    AutoSize = False
    BorderStyle = sbsSunken
    Caption = 'Bits per sample'
    Color = clMenuHighlight
    ParentColor = False
    TabOrder = 7
    Transparent = False
    OnClick = stxtBitsPerSampleClick
  end
  object stxtExtraInfo: TStaticText
    Left = 11
    Top = 397
    Width = 405
    Height = 70
    AutoSize = False
    BevelInner = bvNone
    BevelKind = bkFlat
    Caption = '-'
    Color = clWhite
    ParentColor = False
    TabOrder = 8
    Transparent = False
  end
end
