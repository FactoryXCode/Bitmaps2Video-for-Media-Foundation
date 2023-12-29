object DemoWMFMain: TDemoWMFMain
  Left = 0
  Top = 0
  Caption = 'DemoWMFMain'
  ClientHeight = 795
  ClientWidth = 1164
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlSlideShow: TPanel
    Left = 0
    Top = 0
    Width = 1164
    Height = 761
    Align = alClient
    TabOrder = 0
    object Bevel3: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 19
      Width = 1156
      Height = 738
      Margins.Top = 18
      Align = alClient
      ExplicitTop = 17
    end
    object Bevel2: TBevel
      Left = 463
      Top = 395
      Width = 687
      Height = 378
    end
    object Bevel12: TBevel
      Left = 469
      Top = 456
      Width = 675
      Height = 272
    end
    object Bevel4: TBevel
      Left = 639
      Top = 65
      Width = 511
      Height = 301
    end
    object Bevel1: TBevel
      Left = 12
      Top = 395
      Width = 445
      Height = 369
    end
    object Label12: TLabel
      Left = 472
      Top = 734
      Width = 95
      Height = 15
      Alignment = taRightJustify
      Caption = 'Audio Start [ms] '
    end
    object imgPreview: TImage
      Left = 643
      Top = 75
      Width = 501
      Height = 285
      Center = True
      ParentShowHint = False
      Proportional = True
      ShowHint = False
    end
    object ImageCount: TLabel
      Left = 239
      Top = 54
      Width = 68
      Height = 15
      Alignment = taCenter
      Caption = 'ImageCount'
      Layout = tlCenter
    end
    object Label14: TLabel
      Left = 476
      Top = 418
      Width = 71
      Height = 15
      Alignment = taRightJustify
      Caption = 'Audio Codec'
    end
    object lblRenderingOrder: TLabel
      Left = 460
      Top = 54
      Width = 94
      Height = 15
      Caption = 'Rendering Order'
    end
    object Label7: TLabel
      Left = 28
      Top = 461
      Width = 145
      Height = 15
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Effect TIme'
    end
    object StaticText1: TStaticText
      Left = 15
      Top = 10
      Width = 114
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvNone
      BevelKind = bkFlat
      Caption = 'SlideShow'
      TabOrder = 0
      Transparent = False
    end
    object butRootFolder: TButton
      Left = 10
      Top = 44
      Width = 121
      Height = 25
      Caption = 'Change Root Folder'
      TabOrder = 1
      OnClick = butRootFolderClick
    end
    object chkCropLandscape: TCheckBox
      Left = 28
      Top = 537
      Width = 385
      Height = 17
      Hint = 'Crops the original image to the given video size.'
      Caption = 'Crop landscape images to video size'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object chkBackground: TCheckBox
      Left = 28
      Top = 519
      Width = 385
      Height = 17
      Hint = 'Run the renderer on background.'
      Caption = 'Run in background thread'
      Ctl3D = True
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      WordWrap = True
    end
    object chkAddAudio: TCheckBox
      Left = 28
      Top = 418
      Width = 385
      Height = 17
      Hint = 'A dialog will be shown to add an audio file.'
      Caption = 'Add an audio file'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = chkAddAudioClick
    end
    object chkZoomInOut: TCheckBox
      Left = 28
      Top = 558
      Width = 385
      Height = 17
      Caption = 'Include ZoomInOut-transitions (slows it down)'
      TabOrder = 6
      WordWrap = True
    end
    object chkDebugTiming: TCheckBox
      Left = 28
      Top = 581
      Width = 385
      Height = 17
      Caption = 'Debug Timing (Displays encoded timestamp in seconds)'
      TabOrder = 7
      WordWrap = True
    end
    object butWriteSlideshow: TButton
      Left = 28
      Top = 603
      Width = 109
      Height = 26
      Hint = 'Ceate slideshow from all selected images in the current folder'
      Caption = 'Render'
      TabOrder = 8
      WordWrap = True
      OnClick = butWriteSlideshowClick
    end
    object spedAudioStartTime: TSpinEdit
      Left = 573
      Top = 731
      Width = 93
      Height = 24
      Increment = 1000
      MaxValue = 0
      MinValue = 0
      TabOrder = 9
      Value = 0
    end
    object StaticText2: TStaticText
      Left = 23
      Top = 386
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvNone
      BevelKind = bkFlat
      Caption = 'Render options'
      TabOrder = 10
      Transparent = False
    end
    object StaticText3: TStaticText
      Left = 475
      Top = 386
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvNone
      BevelKind = bkFlat
      Caption = 'Audio options'
      TabOrder = 11
      Transparent = False
    end
    object StaticText4: TStaticText
      Left = 651
      Top = 54
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvNone
      BevelKind = bkFlat
      Caption = 'Preview'
      TabOrder = 12
      Transparent = False
    end
    object Panel3: TPanel
      Left = 15
      Top = 75
      Width = 218
      Height = 285
      TabOrder = 2
    end
    object cbxAudioCodec: TComboBox
      Left = 553
      Top = 415
      Width = 332
      Height = 23
      Hint = 'Choose an audio codec.'
      Style = csDropDownList
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ItemIndex = 0
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      Text = 'Not Selected'
      OnCloseUp = cbxAudioCodecCloseUp
      Items.Strings = (
        'Not Selected'
        'Advanced Audio Coding (AAC)'
        'Dolby AC-3 audio (Dolby Digital Audio Encoder)'
        'MPEG-2 Audio (MP3)'
        'ALAC (Apple Losless)'
        'WMAudio Lossless'
        'WMAudio Version 8'
        'WMAudio Version 9 (Pro)')
    end
    object lbxFileBox: TCheckListBox
      Left = 236
      Top = 75
      Width = 223
      Height = 286
      Hint = 'DoublClick to add a duplicate to the Rendering Order.'
      OnClickCheck = lbxFileBoxClickCheck
      Flat = False
      ItemHeight = 15
      ParentShowHint = False
      ShowHint = True
      TabOrder = 14
      OnClick = lbxFileBoxClick
      OnDblClick = lbxFileBoxDblClick
    end
    object StaticText12: TStaticText
      Left = 482
      Top = 444
      Width = 148
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvNone
      BevelKind = bkFlat
      Caption = 'Codec Information'
      TabOrder = 15
      Transparent = False
    end
    object mmoAudioCodecDescr: TMemo
      Left = 482
      Top = 470
      Width = 657
      Height = 251
      Color = clInfoBk
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Stencil'
      Font.Pitch = fpFixed
      Font.Style = []
      Lines.Strings = (
        'mmoAudioCodecDescr')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 16
      WantReturns = False
    end
    object lbxRenderingOrder: TListBox
      Left = 460
      Top = 75
      Width = 177
      Height = 286
      Hint = 'Use drag and drop to change the rendering order.'
      AutoCompleteDelay = 100
      DragMode = dmAutomatic
      ItemHeight = 15
      ParentShowHint = False
      ShowHint = True
      TabOrder = 17
      OnClick = lbxRenderingOrderClick
      OnDragDrop = lbxRenderingOrderDragDrop
      OnDragOver = lbxRenderingOrderDragOver
      OnStartDrag = lbxRenderingOrderStartDrag
    end
    object butPlay: TButton
      Left = 143
      Top = 603
      Width = 109
      Height = 26
      Hint = 'Ceate slideshow from all selected images in the current folder'
      Caption = 'Play Result'
      TabOrder = 18
      Visible = False
      WordWrap = True
      OnClick = butPlayClick
    end
    object cbxSetPresentationDuration: TCheckBox
      Left = 41
      Top = 438
      Width = 385
      Height = 17
      Hint = 'A dialog will be shown to add an audio file.'
      Caption = 'Set presentation length to audio file duration'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 19
    end
    object spedEffectDuration: TSpinEdit
      Left = 173
      Top = 458
      Width = 93
      Height = 24
      Increment = 1000
      MaxValue = 0
      MinValue = 0
      TabOrder = 20
      Value = 0
    end
  end
  object pnlTranscoder: TPanel
    Left = 0
    Top = 0
    Width = 1164
    Height = 761
    Align = alClient
    TabOrder = 1
    object Bevel5: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 19
      Width = 1156
      Height = 738
      Margins.Top = 18
      Align = alClient
      ExplicitTop = 17
    end
    object TranscoderInput: TLabel
      Left = 131
      Top = 47
      Width = 93
      Height = 15
      Caption = 'TranscoderInput'
    end
    object Label19: TLabel
      Left = 10
      Top = 303
      Width = 1141
      Height = 89
      AutoSize = False
      Caption = 
        'Transcode the video-stream and the 1st audio-stream of the input' +
        '-video to output using the encoder-settings to the left.  Note t' +
        'hat the number of audio-streams reported in the input-box is usu' +
        'ally wrong for .vob. I see no way to get it right at the moment,' +
        ' ideas welcome.   For .mkv with multiple audio-streams the info ' +
        'is right. '
      Layout = tlCenter
      WordWrap = True
    end
    object StaticText5: TStaticText
      Left = 10
      Top = 9
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Transcoder'
      TabOrder = 0
      Transparent = False
    end
    object Button1: TButton
      Left = 10
      Top = 42
      Width = 105
      Height = 25
      Caption = 'Pick input video'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 10
      Top = 101
      Width = 105
      Height = 25
      Caption = 'Transcode'
      TabOrder = 2
      OnClick = Button3Click
    end
    object CheckBox1: TCheckBox
      Left = 9
      Top = 73
      Width = 215
      Height = 17
      Caption = 'Crop to aspect'
      TabOrder = 3
    end
    object Button4: TButton
      Left = 9
      Top = 132
      Width = 105
      Height = 25
      Caption = 'Abort'
      TabOrder = 4
      OnClick = Button4Click
    end
    object Memo2: TMemo
      Left = 10
      Top = 163
      Width = 1140
      Height = 138
      Color = clInfoBk
      Lines.Strings = (
        'Memo2')
      TabOrder = 5
    end
  end
  object pnlAnimation: TPanel
    Left = 0
    Top = 0
    Width = 1164
    Height = 761
    Align = alClient
    TabOrder = 5
    object Bevel8: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 19
      Width = 1156
      Height = 738
      Margins.Top = 18
      Align = alClient
      ExplicitTop = 17
    end
    object Label9: TLabel
      Left = 10
      Top = 45
      Width = 1141
      Height = 44
      AutoSize = False
      Caption = 
        'Demo of the method TBitmapEncoderWMF.AddFrame. A sequence of dra' +
        'wings to the canvas of a TBitmap is encoded to video. Spends mos' +
        't of its time drawing to canvas.'
      Color = clInfoBk
      ParentColor = False
      Transparent = False
      Layout = tlCenter
      WordWrap = True
    end
    object Preview: TPaintBox
      Left = 11
      Top = 100
      Width = 1140
      Height = 594
      OnPaint = PreviewPaint
    end
    object Label1: TLabel
      Left = 12
      Top = 700
      Width = 46
      Height = 15
      Caption = 'Preview'
    end
    object StaticText8: TStaticText
      Left = 10
      Top = 9
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Animation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Transparent = False
    end
    object WriteAnimation: TButton
      Left = 8
      Top = 721
      Width = 96
      Height = 25
      Caption = 'Render'
      TabOrder = 1
      OnClick = WriteAnimationClick
    end
  end
  object pnlCombinedVideo: TPanel
    Left = 0
    Top = 0
    Width = 1164
    Height = 761
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object Bevel7: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 19
      Width = 1156
      Height = 562
      Margins.Top = 18
      Align = alClient
      ExplicitHeight = 572
    end
    object Bevel9: TBevel
      Left = 332
      Top = 228
      Width = 733
      Height = 348
    end
    object StartImageFile: TLabel
      Left = 157
      Top = 37
      Width = 80
      Height = 15
      Caption = 'StartImageFile'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object EndImageFile: TLabel
      Left = 157
      Top = 68
      Width = 77
      Height = 15
      Caption = 'EndImageFile'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object VideoClipFile: TLabel
      Left = 157
      Top = 99
      Width = 73
      Height = 15
      Caption = 'VideoClipFile'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object AudioFileName: TLabel
      Left = 157
      Top = 129
      Width = 85
      Height = 15
      Caption = 'AudioFileName'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object FrameBox: TPaintBox
      Left = 339
      Top = 244
      Width = 715
      Height = 325
      OnPaint = FrameBoxPaint
    end
    object lblCombinedMovieInfo: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 587
      Width = 1156
      Height = 170
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ShowAccelChar = False
      Transparent = False
      Layout = tlCenter
      WordWrap = True
    end
    object Label11: TLabel
      Left = 1080
      Top = 207
      Width = 39
      Height = 15
      Caption = 'Frame:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel10: TBevel
      Left = 10
      Top = 228
      Width = 316
      Height = 348
    end
    object StaticText7: TStaticText
      Left = 9
      Top = 11
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Combined video'
      TabOrder = 0
      Transparent = False
    end
    object PickStartImage: TButton
      Left = 9
      Top = 33
      Width = 134
      Height = 25
      Caption = 'Pick start-image'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = PickStartImageClick
    end
    object PickEndImage: TButton
      Left = 9
      Top = 65
      Width = 134
      Height = 25
      Caption = 'Pick end image'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = PickEndImageClick
    end
    object PickVideo: TButton
      Left = 9
      Top = 98
      Width = 134
      Height = 25
      Caption = 'Pick video clip'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = PickVideoClick
    end
    object PickAudio: TButton
      Left = 9
      Top = 130
      Width = 134
      Height = 25
      Caption = 'Pick audio'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = PickAudioClick
    end
    object CombineToVideo: TButton
      Left = 8
      Top = 163
      Width = 134
      Height = 25
      Caption = 'Render'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = CombineToVideoClick
    end
    object Memo1: TMemo
      Left = 19
      Top = 245
      Width = 301
      Height = 328
      Color = clInfoBk
      Font.Charset = ANSI_CHARSET
      Font.Color = clActiveCaption
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
    end
    object FrameNo: TSpinEdit
      Left = 1080
      Top = 228
      Width = 64
      Height = 24
      Increment = 10
      MaxValue = 10000
      MinValue = 1
      TabOrder = 7
      Value = 1
      OnChange = FrameNoChange
    end
    object StaticText9: TStaticText
      Left = 339
      Top = 219
      Width = 112
      Height = 20
      Hint = 'See uTransformer.GetFrameBitmap'
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Video Thumbnail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Transparent = False
    end
    object StaticText10: TStaticText
      Left = 19
      Top = 219
      Width = 112
      Height = 20
      Hint = 'See uTransformer.GetVideoInfo'
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Info for input video'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      Transparent = False
    end
  end
  object pnlSettings: TPanel
    Left = 0
    Top = 0
    Width = 1164
    Height = 761
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    DesignSize = (
      1164
      761)
    object Bevel6: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 19
      Width = 1156
      Height = 738
      Margins.Top = 18
      Align = alClient
      ExplicitTop = 17
    end
    object Label2: TLabel
      Left = 8
      Top = 6
      Width = 110
      Height = 15
      Caption = 'Choose file format: '
    end
    object Label3: TLabel
      Left = 63
      Top = 68
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Supported Codecs'
    end
    object lblCodecInfo: TLabel
      Left = 514
      Top = 49
      Width = 617
      Height = 185
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      WordWrap = True
    end
    object Label4: TLabel
      Left = 16
      Top = 99
      Width = 152
      Height = 15
      Alignment = taRightJustify
      Caption = 'Resolution and aspectratio'
    end
    object Label5: TLabel
      Left = 76
      Top = 127
      Width = 92
      Height = 15
      Hint = '(recommended: >=60)'
      Alignment = taRightJustify
      Caption = 'Encoding quality'
      ParentShowHint = False
      ShowHint = True
    end
    object Label6: TLabel
      Left = 106
      Top = 157
      Width = 62
      Height = 15
      Hint = 'Framerate in frames per second (fps)'
      Alignment = taRightJustify
      Caption = 'Frame rate'
      ParentShowHint = False
      ShowHint = True
    end
    object Label8: TLabel
      Left = 89
      Top = 37
      Width = 79
      Height = 15
      Alignment = taRightJustify
      Caption = 'Output format'
    end
    object Label13: TLabel
      Left = 514
      Top = 28
      Width = 104
      Height = 15
      Alignment = taRightJustify
      Caption = 'Codec Information'
    end
    object Label20: TLabel
      Left = 15
      Top = 311
      Width = 106
      Height = 15
      Caption = 'Output file location'
    end
    object StaticText6: TStaticText
      Left = 15
      Top = 11
      Width = 112
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'Settings'
      TabOrder = 0
      Transparent = False
    end
    object cbxFileExt: TComboBox
      Left = 179
      Top = 34
      Width = 92
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbxFileExtChange
      Items.Strings = (
        '.mp4'
        '.avi')
    end
    object cbxCodecs: TComboBox
      Left = 179
      Top = 65
      Width = 171
      Height = 23
      Style = csDropDownList
      TabOrder = 2
      OnChange = cbxCodecsChange
    end
    object cbxResolution: TComboBox
      Left = 179
      Top = 96
      Width = 323
      Height = 23
      Style = csDropDownList
      TabOrder = 3
      OnChange = cbxResolutionChange
      Items.Strings = (
        'SD    360p  (640 x 360)'
        'SD    480p  (640 x 480)'
        'SD    480p  (854 x 480)'
        'HD    720p  (1280 x 720)'
        'FHD  1080p  (1920 x 1080)'
        '2K   1080p  (2048 x 1080)'
        'QHD  1440p  (2560 x 1440)'
        '4K   2160p  (3840 x 2160)')
    end
    object spedSetQuality: TSpinEdit
      Left = 180
      Top = 124
      Width = 57
      Height = 24
      Hint = '(recommended: >=60)'
      MaxValue = 100
      MinValue = 10
      TabOrder = 4
      Value = 70
    end
    object cbxFrameRates: TComboBox
      Left = 179
      Top = 154
      Width = 58
      Height = 23
      Hint = 'Framerate in frames per second (fps)'
      Style = csDropDownList
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnChange = cbxFrameRatesChange
    end
    object edLocation: TEdit
      Left = 15
      Top = 329
      Width = 1114
      Height = 23
      Hint = 'Double Click to open the file.'
      AutoSize = False
      BorderStyle = bsNone
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsUnderline]
      ParentFont = False
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 6
      OnDblClick = edLocationDblClick
    end
  end
  object stbStatus: TStatusBar
    Left = 0
    Top = 761
    Width = 1164
    Height = 34
    Margins.Left = 12
    Panels = <>
    SimplePanel = True
    SimpleText = 'Status'
    SizeGrip = False
  end
  object FODAudio: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Audio files (*.wav;*.mp3;*.aac;*.wma)'
        FileMask = '*.wav;*.mp3;*.aac;*.wma'
      end
      item
        DisplayName = 'Audio- and video-files'
        FileMask = '*.wav;*.mp3;*.aac;*.wma;*.avi;*.mp4;*.mpg;*.mkv;*.vob;*.wmv'
      end
      item
        DisplayName = 'Any'
        FileMask = '*.*'
      end>
    FileTypeIndex = 2
    Options = []
    Title = 'Choose an audio file.'
    Left = 970
    Top = 7
  end
  object OD: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 852
    Top = 7
  end
  object FODPic: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'All supported'
        FileMask = '*.bmp;*.jpg;*.png;*.gif'
      end
      item
        DisplayName = 'All'
        FileMask = '*.*'
      end>
    Options = []
    Left = 911
    Top = 7
  end
  object FODVideo: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'All supported'
        FileMask = '*.avi;*.mp4;*.mkv;*.mpg;*.wmv;*.vob'
      end
      item
        DisplayName = 'All'
        FileMask = '*.*'
      end>
    Options = []
    Left = 793
    Top = 7
  end
  object ImageList1: TImageList
    Left = 1029
    Top = 7
    Bitmap = {
      494C010101000800400010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000000000000000000046819A004681
      9A0046819A0046819A0046819A0046819A003B6F8800305E7700305E7700305E
      7700305E7700305E7700305E7700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000046819A0072BEDB006FBA
      D7006FBAD7006FBAD7006FBAD70072BEDB0046819A004C9EC5004D9FC6004D9F
      C6004D9FC6004D9FC6004D9FC600305E77000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000048839B0071BEDA006FBA
      D6006FBAD6006FBAD6006FBAD60071BEDA0046819A0052A4CB0052A5CB0053A5
      CB0052A5CB0052A5CB00FF965400336079000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004D859E0074C2DD0072BE
      D90072BED90072BED90072BED90074C2DD0046819A0057AAD00058ABD00058AB
      D00058ABD00058ABD000EAEAEA0039657E000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000538BA10077C6E00075C2
      DC0075C2DC0075C2DC0075C2DC0077C5E00046819A005EB0D5005EB1D5005FB1
      D5005EB1D5005EB1D500EAEAEA00406C83000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A8FA4007ACAE30078C6
      DF0078C6DF0078C6DF0078C6DF0079C9E3004A849C0064B6D90065B6DA0065B6
      DA0065B6DA0065B6DA00EAEAEA00497289000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006294A8007CCEE6007BCA
      E2007BCAE2007BCAE2007BCAE2007CCEE60050889F0069B2D2006BBBDE006BBC
      DE006BBCDE006BBCDE006BBCDE00517A90000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006A9BAD007FD2E9007ECE
      E5007ECEE5007ECEE5007ECEE5007FD0E7007BC4DA00558BA20071BEDF0071C1
      E20071C1E20071C0E200517A9000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000073A0B10082D6EC0081D2
      E80081D2E80081D2E80081D2E80081D2E80082D4EA0080CDE3005A8FA40078C6
      E70078C6E6007296A70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007CA6B50085D9EF0084D6
      EB0084D6EB0084D6EB0084D6EB0084D6EB0084D6EB0085DCF1006294A9007FCB
      EA007FCAEA007296A70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000083ACBA0087DDF20087DA
      EE0087DAEE0087DAEE0087DAEE0087DAEE0087DAEE0087DEF2006A9AAD0087CF
      EE0086CFEE007C9EAE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008BB2BE008AE1F5008ADE
      F1008ADEF1008ADEF1008ADEF1008ADEF1008ADEF1008AE2F50072A0B1008ED3
      F1008DD3F10086A6B60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000091B6C1008CE5F8008CE2
      F4008CE2F4008CE2F4008CE2F4008CE2F4008CE2F4008CE6F8007BA6B50095D7
      F40095D7F4008EAEBC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000098BAC50090E9FB0090E6
      F70090E6F70090E6F70090E6F70090E6F70090E6F70090E9FB0084ACBA009BDB
      F6009BDBF60096B4C20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000009CBDC60091F2FF0092EE
      FE0092EEFE0092EEFE0092EEFE0092EEFE0092EEFE0091F2FF008BB1BE00A2DF
      F900A1DFF9009EBBC70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000009DBEC7009DBE
      C7009DBEC70099BCC50097BAC40097BAC30095B8C30094B7C2009BBBC600A3BF
      CB00A3BFCC000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00C0010000000000008000000000000000
      8000000000000000800000000000000080000000000000008000000000000000
      8000000000000000800100000000000080030000000000008003000000000000
      8003000000000000800300000000000080030000000000008003000000000000
      8003000000000000C00700000000000000000000000000000000000000000000
      000000000000}
  end
  object MainMenu1: TMainMenu
    Left = 734
    Top = 7
    object File1: TMenuItem
      Caption = 'File'
      object mnuNew: TMenuItem
        Caption = '&New'
        Hint = 'Create a new file'
        OnClick = mnuNewClick
      end
      object mnuPlay: TMenuItem
        Caption = 'Play'
        Enabled = False
        Hint = 'Play output file'
        OnClick = mnuPlayClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Caption = 'E&xit'
        OnClick = mnuExitClick
      end
    end
    object Render1: TMenuItem
      AutoCheck = True
      Caption = 'Options'
      object mnuCreateAnimation: TMenuItem
        Caption = '&Animation'
        Hint = 'Create an animation from canvas.'
        OnClick = mnuCreateAnimationClick
      end
      object mnuImageSlideshow: TMenuItem
        Caption = '&Slideshow'
        Hint = 'Create an image slideshow.'
        OnClick = mnuImageSlideshowClick
      end
      object mnuCombinedMovie: TMenuItem
        Caption = 'Combined &Movie'
        Hint = 'Cre'
        OnClick = mnuCombinedMovieClick
      end
      object mnuTranscode: TMenuItem
        Caption = 'Transcode'
        OnClick = mnuTranscodeClick
      end
    end
  end
end
