unit uDemoWMFMain;

interface

uses
  {Winapi}
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  Winapi.ShellAPI,
  Winapi.ShlObj,
  {System}
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  System.Math,
  {$IF COMPILERVERSION > 28.0}
  System.ImageList,
  {$ENDIF} // Delphi version XE4 or higher.
  System.Types,
  System.Diagnostics,
  System.IOUtils,
  System.Threading, // Delphi version XE7 or higher.
  {VCL}
  VCL.Graphics,
  VCL.Controls,
  VCL.Forms,
  VCL.Dialogs,
  VCL.StdCtrls,
  VCL.ExtCtrls,
  VCL.ImgList,
  VCL.ComCtrls,
  VCL.Samples.Spin,
  VCL.Menus,
  Vcl.CheckLst,
  // Needed by TImage
  VCL.Imaging.jpeg,
  VCL.Imaging.pngimage,
  // ================
  {MediaFoundation}
  WinApi.MediaFoundation.MfVideoStandardsCheat,
  WinApi.MediaFoundationApi.MfApi,
  WinApi.MediaFoundationApi.MfMetLib,
  {Application}
  uDirectoryTree,
  uScaleWMF,
  uScaleCommonWMF,
  uToolsWMF,
  uBitMaps2VideoWMF,
  uTransformer,
  AudioMftClass;

{$WARN SYMBOL_PLATFORM OFF}

const
  MsgUpdate = WM_User + 1;

type
  TListBox = class(VCL.StdCtrls.TListBox)
  private
    fOnSelChange: TNotifyEvent;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;

  public
    property OnSelChange: TNotifyEvent read fOnSelChange write fOnSelChange;
  end;

  TDemoWMFMain = class(TForm)
    FODAudio: TFileOpenDialog;
    OD: TFileOpenDialog;
    FODPic: TFileOpenDialog;
    FODVideo: TFileOpenDialog;
    ImageList1: TImageList;
    stbStatus: TStatusBar;
    pnlSlideShow: TPanel;
    Bevel3: TBevel;
    StaticText1: TStaticText;
    butRootFolder: TButton;
    Panel3: TPanel;
    chkCropLandscape: TCheckBox;
    Bevel1: TBevel;
    chkBackground: TCheckBox;
    chkAddAudio: TCheckBox;
    chkZoomInOut: TCheckBox;
    chkDebugTiming: TCheckBox;
    Label12: TLabel;
    butWriteSlideshow: TButton;
    spedAudioStartTime: TSpinEdit;
    Bevel2: TBevel;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    imgPreview: TImage;
    Bevel4: TBevel;
    StaticText4: TStaticText;
    ImageCount: TLabel;
    pnlTranscoder: TPanel;
    Bevel5: TBevel;
    StaticText5: TStaticText;
    pnlSettings: TPanel;
    StaticText6: TStaticText;
    cbxFileExt: TComboBox;
    Label3: TLabel;
    cbxCodecs: TComboBox;
    lblCodecInfo: TLabel;
    Label4: TLabel;
    cbxResolution: TComboBox;
    Label5: TLabel;
    spedSetQuality: TSpinEdit;
    Label6: TLabel;
    cbxFrameRates: TComboBox;
    Label8: TLabel;
    pnlCombinedVideo: TPanel;
    Bevel7: TBevel;
    StaticText7: TStaticText;
    PickStartImage: TButton;
    StartImageFile: TLabel;
    EndImageFile: TLabel;
    PickEndImage: TButton;
    PickVideo: TButton;
    VideoClipFile: TLabel;
    PickAudio: TButton;
    AudioFileName: TLabel;
    CombineToVideo: TButton;
    Memo1: TMemo;
    FrameBox: TPaintBox;
    lblCombinedMovieInfo: TLabel;
    TranscoderInput: TLabel;
    Button1: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Button4: TButton;
    Memo2: TMemo;
    Label19: TLabel;
    Bevel6: TBevel;
    pnlAnimation: TPanel;
    Bevel8: TBevel;
    StaticText8: TStaticText;
    Label9: TLabel;
    Preview: TPaintBox;
    WriteAnimation: TButton;
    Label1: TLabel;
    FrameNo: TSpinEdit;
    Label11: TLabel;
    Bevel9: TBevel;
    Label13: TLabel;
    Label20: TLabel;
    edLocation: TEdit;
    Label14: TLabel;
    cbxAudioCodec: TComboBox;
    lbxFileBox: TCheckListBox;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    Bevel10: TBevel;
    StaticText12: TStaticText;
    Bevel12: TBevel;
    mmoAudioCodecDescr: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnuNew: TMenuItem;
    mnuPlay: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    Render1: TMenuItem;
    mnuCreateAnimation: TMenuItem;
    mnuImageSlideshow: TMenuItem;
    mnuCombinedMovie: TMenuItem;
    mnuTranscode: TMenuItem;
    lbxRenderingOrder: TListBox;
    lblRenderingOrder: TLabel;
    butPlay: TButton;
    cbxSetPresentationDuration: TCheckBox;
    spedEffectDuration: TSpinEdit;
    Label7: TLabel;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure WriteAnimationClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure butWriteSlideshowClick(Sender: TObject);
    procedure cbxFileExtChange(Sender: TObject);
    procedure cbxCodecsChange(Sender: TObject);
    procedure cbxResolutionChange(Sender: TObject);
    procedure PreviewPaint(Sender: TObject);
    procedure butRootFolderClick(Sender: TObject);
    procedure PickStartImageClick(Sender: TObject);
    procedure PickEndImageClick(Sender: TObject);
    procedure PickVideoClick(Sender: TObject);
    procedure PickAudioClick(Sender: TObject);

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure CombineToVideoClick(Sender: TObject);

    procedure FrameNoChange(Sender: TObject);
    procedure FrameBoxPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cbxFrameRatesChange(Sender: TObject);
    procedure mnuPlayClick(Sender: TObject);
    procedure mnuImageSlideshowClick(Sender: TObject);
    procedure mnuCreateAnimationClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure pnlVideoFromImagesClick(Sender: TObject);
    procedure mnuCombinedMovieClick(Sender: TObject);
    procedure mnuTranscodeClick(Sender: TObject);
    procedure edLocationDblClick(Sender: TObject);
    procedure lbxFileBoxClick(Sender: TObject);
    procedure cbxAudioCodecCloseUp(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure lbxFileBoxClickCheck(Sender: TObject);
    procedure lbxRenderingOrderClick(Sender: TObject);
    procedure butPlayClick(Sender: TObject);
    procedure chkAddAudioClick(Sender: TObject);
    procedure lbxRenderingOrderDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbxRenderingOrderStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure lbxRenderingOrderDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbxFileBoxDblClick(Sender: TObject);

  private
    { Private-Declarations }
    iSourcePos: Integer;
    bDblClick: Boolean;
    fDirectoryTree: TDirectoryTree;
    fFileList: TStringlist;
    fSelectedFilesList: TStringList;
    fOutputFile: string;
    fCodecList: TCodecIdArray;
    fAudioCodec: TGUID;
    fVideoStandardsCheat: TVideoStandardsCheat;
    fWriting: Boolean;
    fFramebm: TBitmap;
    fUserAbort: Boolean;
    fAspectRatio: Double;
    iVideoWidth: Integer;
    iVideoHeight: Integer;
    iSelectedAudioFormat: Integer;
    fSelectedAudioFormat: TMFAudioFormat;
    fAudioMft: TAudioMft;
    fAudioCodecDescr: string;
    fEffectDuration: Int64;

    function GetOutputFileName(): string;
    procedure DoUpdate(var msg: TMessage); message MsgUpdate;
    procedure DirectoryTreeChange(Sender: TObject; node: TTreeNode);

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure MakeSlideshow(const sl: TStringlist;
                            const wic: TWicImage;
                            const bm: TBitmap;
                            const bme: TBitmapEncoderWMF;
                            var Done: Boolean;
                            threaded: Boolean);

    procedure GetResolutions();
    procedure SetResolution();

    procedure GetFramerates();
    function SetFrameRate(): Double;

    function GetDoCrop(): Boolean;
    function GetDoZoomInOut(): Boolean;
    function GetAudioFile(): string;
    function GetQuality(): Integer;
    function GetAudioBitRate(): Double; // Bitrate in kbps.
    function GetAudioSampleRate(): Double; // Sample rate in kHz.
    function GetAudioStart(): Int64;
    function GetAudioDialog(): Boolean;
    procedure TransCodeProgress(Sender: TObject;
                                FrameCount: Cardinal;
                                VideoTime: Int64;
                                var DoAbort: Boolean);
    procedure DisplayVideoInfo(const aMemo: TMemo;
                               const VideoInfo: TVideoInfo);
    function GetSelectedFiles(): Integer;

  public
    { Public-Declarations }
    // properties which read the input parameters for the bitmap-encoder
    // off the controls of the form
    property OutputFileName: string read GetOutputFileName;
    property SelectedFiles: Integer read GetSelectedFiles;
    property Aspect: Double read fAspectRatio;
    property VideoHeight: Integer read iVideoHeight;
    property VideoWidth: Integer read iVideoWidth;
    property FrameRate: Double read SetFrameRate;
    property Quality: Integer read GetQuality;
    property DoCrop: Boolean read GetDoCrop;
    property DoZoomInOut: Boolean read GetDoZoomInOut;

    property CurrentAudioCodec: TGUID read fAudioCodec;
    property CurrentAudioCodecName: string read fAudioCodecDescr;
    property AudioFile: string read GetAudioFile;
    property AudioSampleRate: Double read GetAudioSampleRate;
    property AudioBitRate: Double read GetAudioBitRate;
    property AudioStart: Int64 read GetAudioStart;
    property AudioDialog: Boolean read GetAudioDialog;

    property EffectDuration: Int64 read fEffectDuration;

  end;

var
  DemoWMFMain: TDemoWMFMain;

implementation

{$R *.dfm}

uses
  dlgAudioFormats;


function PIDLToPath(IdList: PItemIDList): string;
begin
  SetLength(Result,
            MAX_PATH);

  if SHGetPathFromIdList(IdList,
                         PChar(Result)) then
    SetLength(Result,
              StrLen(PChar(Result)))
  else
    Result := '';
end;


function PidlFree(var IdList: PItemIDList): Boolean;
var
  Malloc: IMalloc;

begin
  Result := False;
  if (IdList = nil) then
    Result := True
  else
  begin
    if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
    begin
      Malloc.Free(IdList);
      IdList := nil;
      Result := True;
    end;
  end;
end;


function GetDesktopFolder: string;
var
  FolderPidl: PItemIDList;
begin
  if Succeeded(SHGetSpecialFolderLocation(0,
                                          $0000,
                                          FolderPidl)) then
  begin
    Result := PIDLToPath(FolderPidl);
    PidlFree(FolderPidl);
  end
  else
    Result := '';
end;


procedure TDemoWMFMain.WriteAnimationClick(Sender: TObject);
var
  i: Integer;
  j: Integer;
  w: Integer;
  h: Integer;
  A: Double;
  r: Double;
  theta: Double;
  dtheta: Double;
  xCenter: Integer;
  yCenter: Integer;
  scale: Double;
  bm: TBitmap;
  pre: TBitmap;
  points: array of TPoint;
  jmax: Integer;
  bme: TBitmapEncoderWMF;
  StopWatch: TStopWatch;

  function dist(o: Double): Double; inline;
    begin
      Result := 2 - 0.2 * o;
    end;

  // map from world ([-2,2] x [-2,2]) to bitmap
  function map(p: TPointF): TPoint;
    begin
      Result.x := Round(xCenter + scale * p.x);
      Result.y := Round(yCenter - scale * p.y);
    end;

begin

  if fWriting then
    begin
      ShowMessage('Encoding in progress, wait until finished.');
      Exit;
    end;

  fWriting := True;
  try
    h := VideoHeight;
    w := VideoWidth;
    Preview.Width := Round(Aspect * Preview.Height);
    StopWatch := TStopWatch.Create;
    bme := TBitmapEncoderWMF.Create;

    try
      // Initialize the bitmap-encoder
      bme.Initialize(OutputFileName,
                     w,
                     h,
                     Quality,
                     FrameRate,
                     fCodecList[cbxCodecs.ItemIndex],
                     fSelectedAudioFormat,
                     cfBicubic);

      bm := TBitmap.Create();

      try
        // AntiAlias 2*Video-Height
        bm.SetSize(2 * w,
                   2 * h);
        xCenter := bm.Width div 2;
        yCenter := bm.Height div 2;
        scale := bm.Height / 4;

        bm.Canvas.brush.color := clMaroon;
        bm.Canvas.pen.color := clYellow;
        bm.Canvas.pen.Width := Max(h div 180,
                               2);

        dtheta := 2 / 150 * Pi;
        StopWatch.Start();

        // Draw a sequence of spirals
        for i := 0 to 200 do
          begin
            A := 1 - 1 / 210 * i;
            jmax := trunc(10 / A / dtheta);
            SetLength(points,
                      jmax);
            theta := 0;

            for j := 0 to jmax - 1 do
              begin
                r := dist(A * theta);
                points[j] := map(Pointf(r * cos(theta),
                                        r * sin(theta)));
                theta := theta + dtheta;
              end;

          bm.Canvas.Fillrect(bm.Canvas.clipRect);
          bm.Canvas.PolyLine(points);

          bme.AddFrame(bm,
                       False);

          stbStatus.SimpleText := Format('Writing frame %d',
                                         [(i + 1)]);
          stbStatus.Repaint();

          if (i mod 10 = 1) then
            begin
              pre := TBitmap.Create;
              try
                uScaleWMF.Resample(Preview.Width,
                                   Preview.Height,
                                   bm,
                                   pre,
                                   cfBilinear,
                                   0,
                                   True,
                                   amIgnore);

                BitBlt(Preview.Canvas.Handle,
                       0,
                       0,
                       pre.Width,
                       pre.Height,
                       pre.Canvas.Handle,
                       0,
                       0,
                       SRCCopy);
              finally
                pre.Free();
              end;
          end;
        end;
        StopWatch.Stop();
        stbStatus.SimpleText := Format('Writing speed including drawing to canvas: %s fps',
                                       [FloatToStrF(bme.FrameCount * 1000 / StopWatch.ElapsedMilliseconds,
                                                    ffFixed,
                                                    5,
                                                    2)]);
        mnuPlay.Enabled := True;

      finally
        bm.Free();
      end;

      bme.Finalize();

    finally
      bme.Free();
    end;

  finally
    fWriting := False;
  end;
end;


function GetRandomZoom: TZoom; inline;
begin
  Result.xCenter := 0.5 + (random - 0.5) * 0.7;
  Result.yCenter := 0.5 + (random - 0.5) * 0.7;
  Result.Radius := min(1 - Result.xCenter, Result.xCenter);
  Result.Radius := min(Result.Radius, 1 - Result.yCenter);
  Result.Radius := min(Result.Radius, Result.yCenter);
  Assert(Result.Radius > 0);
  Result.Radius := 0.5 * Result.Radius;
end;


procedure TDemoWMFMain.MakeSlideshow(const sl: TStringlist;
                                     const wic: TWicImage;
                                     const bm: TBitmap;
                                     const bme: TBitmapEncoderWMF;
                                     var Done: Boolean;
                                     threaded: Boolean);
var
  i: Integer;
  crop: Boolean;
  dice: Single;
  // TZoom is a record (xcenter, ycenter, radius) defining a virtual zoom-rectangle
  // (xcenter-radius, ycenter-radius, xcenter+radius, ycenter+radius).
  // This rectangle should be a sub-rectangle of [0,1]x[0,1].
  // If multipied by the width/height of a target rectangle, it defines
  // an aspect-preserving sub-rectangle of the target.
  Zooms, Zoom: TZoom;
  DoInOut: Boolean;

begin
  wic.LoadFromFile(sl.Strings[0]);
  WicToBmp(wic,
           bm);
  crop := (bm.Width > bm.Height) and DoCrop;

  fEffectDuration := spedEffectDuration.Value;

  if cbxSetPresentationDuration.Checked then
    bme.AddStillImage(bm,
                      //(bme.AudioDuration div fSelectedFilesList.Count) - (EffectDuration + 2000),
                      (bme.AudioDuration div fSelectedFilesList.Count),
                      True,
                      crop)
  else
    bme.AddStillImage(bm,
                      EffectDuration,
                      False,
                      crop);



  PostMessage(Handle,
              MsgUpdate,
              0,
              0);

  if not threaded then
    Application.ProcessMessages;

  for i := 1 to sl.Count - 1 do
    begin
      wic.LoadFromFile(sl.Strings[i]);
      WicToBmp(wic, bm);
      crop := (bm.Width > bm.Height) and DoCrop;
      dice := random;
      DoInOut := DoZoomInOut and (dice < 1 / 3);

      if not DoInOut then
        bme.CrossFadeTo(bm,
                      2000,
                      crop)

      else
        begin
          Zooms := GetRandomZoom;
          Zoom := GetRandomZoom;

          bme.ZoomInOutTransitionTo(bm,
                                    Zooms,
                                    Zoom,
                                    2500,
                                    crop);

       end;

      bme.AddStillImage(bm,
                       4000,
                       False,
                       crop);
      PostMessage(Handle,
                  MsgUpdate,
                  i,
                  0);

      if not threaded then
        Application.ProcessMessages;

  end;
  Done := True;
end;


procedure TDemoWMFMain.butWriteSlideshowClick(Sender: TObject);
var
  bme: TBitmapEncoderWMF;
  bm: TBitmap;
  wic: TWicImage;
  StopWatch: TStopWatch;
  task: itask;
  Done: Boolean;
  sl: TStringlist;
  af: string;
  i: Integer;

begin

  if fWriting then
    begin
      ShowMessage('Rendering in progress, wait until finished.');
      Exit;
    end;

  af := '';

  if AudioDialog then
    af := AudioFile;

  fWriting := True;

  butPlay.Visible := False;
  mnuPlay.Enabled := False;

  // Use a local stringlist because of threading
  sl := TStringlist.Create();

  try

    for i := 0 to fSelectedFilesList.Count - 1 do
      sl.Add(fSelectedFilesList.Strings[i]);

    if (sl.Count = 0) then
      begin
        ShowMessage('No image files selected!');
        Exit;
      end;

    bme := TBitmapEncoderWMF.Create();
    bm := TBitmap.Create();
    wic := TWicImage.Create();
    StopWatch := TStopWatch.Create();

    try
      stbStatus.SimpleText := 'Rendering ...';
      StopWatch.Start();

      try
        bme.Initialize(OutputFileName,
                       VideoWidth,
                       VideoHeight,
                       Quality,
                       FrameRate,
                       fCodecList[cbxCodecs.ItemIndex],
                       fSelectedAudioFormat,
                       cfBicubic,
                       af,
                       AudioStart);
      except
        on eAudioFormatException do
          begin
            ShowMessage('The format of the input file or the settings of bitrate or sample rate are not supported.' +
                        'Try again with different settings.');
            Exit;
          end
        else
          raise;
      end;

      bme.TimingDebug := chkDebugTiming.Checked;

      if chkBackground.Checked then
        begin
          Done := False;
          task := TTask.Run(procedure
                              begin
                                MakeSlideshow(sl,
                                              wic,
                                              bm,
                                              bme,
                                              Done,
                                              True);
                              end);

          while not Done do
            begin
              //Application.ProcessMessages();
              HandleThreadMessages(GetCurrentThread, 10);
              //Sleep(100);
            end;

          task.Wait();
          //Application.ProcessMessages();
          HandleThreadMessages(GetCurrentThread);
        end
      else
        begin
          MakeSlideshow(sl,
                        wic,
                        bm,
                        bme,
                        Done,
                        False);
        end;

      StopWatch.Stop();
      bme.Finalize();

      stbStatus.SimpleText := Format('Rendering finished. Writing speed including decoding of image files and computing transitions: %s fps',
                                     [FloatToStrF(1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds,
                                                  ffFixed,
                                                  5,
                                                  2)]);
      stbStatus.Repaint();
      mnuPlay.Enabled := True;
      butPlay.Visible := True;

    finally
      wic.Free();
      bm.Free();
      bme.Free();
    end;

  finally
    sl.Free();
    fWriting := False;
  end;
end;


procedure TDemoWMFMain.CombineToVideoClick(Sender: TObject);
var
  proceed: Boolean;
  bme: TBitmapEncoderWMF;
  wic: TWicImage;
  bm: TBitmap;
  af: string;
  StopWatch: TStopWatch;
  fps: Double;

begin

  {$IF COMPILERVERSION < 29.0}
    // To prevent hint "fps could not be initialized" on lower versions.
    fps := 0.0;
  {$ENDIF}

  if fWriting then
    begin
      ShowMessage('Encoding in progress, wait until finished.');
      Exit;
    end;

  fWriting := True;

  try

    if not FileExists(AudioFileName.Caption) then
      af := ''
    else
      af := AudioFileName.Caption;

    proceed := FileExists(StartImageFile.Caption) and
               FileExists(EndImageFile.Caption) and
               FileExists(VideoClipFile.Caption);

    proceed := proceed and (VideoClipFile.Caption <> OutputFileName);

    if not proceed then
      begin
        ShowMessage('Pick valid files for the images and the video clip first.' + #13 +
                    'The output filename cannot be identical to the video clip name.');
        Exit;
    end;

    StopWatch := TStopWatch.Create();
    bme := TBitmapEncoderWMF.Create();

    try

      StopWatch.Start();
      stbStatus.SimpleText := 'Preparing ...';

      try
        bme.Initialize(OutputFileName,
                       VideoWidth,
                       VideoHeight,
                       Quality,
                       FrameRate,
                       TCodecID(cbxCodecs.ItemIndex),
                       fSelectedAudioFormat,
                       cfBicubic,
                       af,
                       9000);

      except
        on eAudioFormatException do
          begin
            ShowMessage('The format of the audio file is not supported.');
            Exit;
          end
        else
          raise;
      end;

      wic := TWicImage.Create();
      bm := TBitmap.Create();

      try

        wic.LoadFromFile(StartImageFile.Caption);

        WicToBmp(wic,
                 bm);

        stbStatus.SimpleText := 'Start Image';
        bme.AddStillImage(bm,
                          5000,
                          False,
                          False);

        stbStatus.SimpleText := 'Video Clip';

        try

          bme.OnProgress := TransCodeProgress;
          bme.AddVideo(VideoClipFile.Caption,
                       4000);

        except
          on EVideoFormatException do
            begin
              ShowMessage('Video format of ' +
                          VideoClipFile.Caption +
                          ' is not supported.');
              Exit;
            end
          else
            raise;
        end;

        wic.LoadFromFile(EndImageFile.Caption);

        WicToBmp(wic,
                 bm);

        bme.OnProgress := nil;
        stbStatus.SimpleText := 'End processing image';

        bme.CrossFadeTo(bm,
                        4000,
                        False);

        bme.AddStillImage(bm,
                          5000,
                          False,
                          False);

      finally
        bm.Free();
        wic.Free();
      end;

      StopWatch.Stop();

      fps := (1000 * bme.FrameCount) / StopWatch.ElapsedMilliseconds;

    finally
      // destroy finalizes
      bme.Free();
    end;

    stbStatus.SimpleText := Format('Average writing speed: %d fps',
                                   [FloatToStrF(fps,
                                                ffFixed,
                                                5,
                                                2)]);
    mnuPlay.Enabled := True;

  finally
    fWriting := False;
  end;
end;


procedure TDemoWMFMain.cbxAudioCodecCloseUp(Sender: TObject);
var
  i: Integer;

label
  done;
begin
  iSelectedAudioFormat := 0;
  {
  listed in control's property Items.
  ===================================
  Advanced Audio Coding (AAC)
  Dolby AC-3 audio (Dolby Digital Audio Encoder)
  MPEG-2 Audio (MP3)
  ALAC (Apple Losless)
  WMAudio Lossless
  WMAudio Version 8
  WMAudio Version 9 (Pro)
  }
  case cbxAudioCodec.ItemIndex of
    1: fAudioCodec := MFAudioFormat_AAC;
    2: fAudioCodec := MFAudioFormat_Dolby_AC3;
    3: fAudioCodec := MFAudioFormat_MP3;
    4: fAudioCodec := MFAudioFormat_ALAC; // Apple, Supported in Windows 10 and later.
    5: fAudioCodec := MFAudioFormat_WMAudio_Lossless;
    6: fAudioCodec := MFAudioFormat_WMAudioV8;
    7: fAudioCodec := MFAudioFormat_WMAudioV9;
    else
      goto done;
  end;

  fAudioCodecDescr := cbxAudioCodec.Items[cbxAudioCodec.ItemIndex];
  // List the required audioformat capabilities.

  if (AudioFormatDlg.ShowModal = mrOk) then
    begin
      iSelectedAudioFormat := AudioFormatDlg.iSelectedFormat;
      fSelectedAudioFormat := AudioFormatDlg.fAudioFmts[iSelectedAudioFormat];
    end
  else
    begin
      // User did not select a valid audio format.
      iSelectedAudioFormat := 0;
   end;

  if (iSelectedAudioFormat > 0) then
    begin
      mmoAudioCodecDescr.Clear();
      for i := 0 to AudioFormatDlg.fAudioCodecDescription.Count -1 do
        mmoAudioCodecDescr.Lines.Append(AudioFormatDlg.fAudioCodecDescription.Strings[i]);
      mmoAudioCodecDescr.SelStart := 0;
      mmoAudioCodecDescr.SelLength := 1;
    end;

done:
  if (iSelectedAudioFormat = 0) then
    begin
      ShowMessage('You did not select a valid audio format!');
      cbxAudioCodec.ItemIndex := 0;
    end;
end;


procedure TDemoWMFMain.mnuCombinedMovieClick(Sender: TObject);
begin
  pnlCombinedVideo.BringToFront;
end;


procedure TDemoWMFMain.mnuCreateAnimationClick(Sender: TObject);
begin
  pnlAnimation.BringToFront();
  DirectoryTreeChange(fDirectoryTree,
                      fDirectoryTree.Selected);
end;


procedure TDemoWMFMain.mnuExitClick(Sender: TObject);
begin
  Close();
end;


procedure TDemoWMFMain.Button1Click(Sender: TObject);
var
  VideoInfo: TVideoInfo;

begin
  if not FODVideo.Execute then
    Exit;

  TranscoderInput.Caption := FODVideo.FileName;

  try
    VideoInfo := GetVideoInfo(FODVideo.FileName);
  except
    ShowMessage('The format of the input file is not supported.');
  end;

  DisplayVideoInfo(Memo2,
                   VideoInfo);
end;


procedure TDemoWMFMain.butPlayClick(Sender: TObject);
begin
  mnuPlayClick(Self);
end;


procedure TDemoWMFMain.butRootFolderClick(Sender: TObject);
begin
  if not OD.Execute(self.Handle) then
    Exit;
  fDirectoryTree.NewRootFolder(OD.FileName);
end;


procedure TDemoWMFMain.TransCodeProgress(Sender: TObject;
                                         FrameCount: Cardinal;
                                         VideoTime: Int64;
                                         var DoAbort: Boolean);
var
  min: Integer;
  sec: Integer;

begin
  sec := VideoTime div 1000;
  min := sec div 60;
  sec := sec mod 60;

  stbStatus.SimpleText := Format('Encoding time-stamp: %d:%d',
                                 [min,
                                  sec]);

  stbStatus.Invalidate();
  Application.ProcessMessages();
  DoAbort := fUserAbort;
end;


procedure TDemoWMFMain.Button3Click(Sender: TObject);
begin
  if fWriting then
    begin
      ShowMessage('Encoding in progress, please wait until the process is finished.');
      Exit;
    end;

  fWriting := True;

  try

    stbStatus.SimpleText := 'Processing, please wait...';
    fUserAbort := False;
    TranscodeVideoFile(TranscoderInput.Caption,
                       OutputFileName,
                       TCodecID(cbxCodecs.ItemIndex),
                       fSelectedAudioFormat,
                       Quality,
                       VideoWidth,
                       VideoHeight,
                       FrameRate,
                       CheckBox1.Checked,
                       TransCodeProgress);

    if fUserAbort then
      stbStatus.SimpleText := 'Process aborted!'
    else
      begin
        stbStatus.SimpleText := 'Rendering completed!';
        mnuPlay.Enabled := True;
      end;

  finally

    fWriting := False;
    fUserAbort := False;

  end;
end;


procedure TDemoWMFMain.Button4Click(Sender: TObject);
begin
  fUserAbort := True;
end;


procedure TDemoWMFMain.PickAudioClick(Sender: TObject);
begin
  AudioFileName.Caption := AudioFile;
end;


procedure TDemoWMFMain.cbxCodecsChange(Sender: TObject);
begin
  lblCodecInfo.Caption := CodecInfos[fCodecList[cbxCodecs.ItemIndex]];
  // We don't use a label here, so we can copy the link to clipboard.
  edLocation.Text := Format('The output will be saved to: %s',
                            [OutputFileName]);
end;


procedure TDemoWMFMain.DirectoryTreeChange(Sender: TObject;
                                           node: TTreeNode);
var
  i: Integer;

begin
  fDirectoryTree.GetAllFiles(fFileList,
                             '*.bmp;*.jpg;*.png;*.gif');
  lbxFileBox.Clear();

  for i := 0 to fFileList.Count - 1 do
    lbxFileBox.Items.Add(ExtractFileName(fFileList.Strings[i]));
end;


procedure TDemoWMFMain.lbxFileBoxClick(Sender: TObject);
begin
  // Show a preview of the selected imagefile.
  imgPreview.Picture.LoadFromFile(fFileList.Strings[lbxFileBox.ItemIndex]);
end;


procedure TDemoWMFMain.lbxFileBoxClickCheck(Sender: TObject);
var
  i: Integer;
  n: Integer;
begin
  n := 0;
  // Alternative for Selcount.
  for i := 0 to lbxFileBox.Items.Count -1 do
    if lbxFileBox.Checked[i] then
      Inc(n);

  ImageCount.Caption := Format('%d %s',
                               [n,
                                'images selected (bmp, jpg, png, gif)']);

  // Add or remove checked file to rendering order.
  if lbxFileBox.Checked[lbxFileBox.ItemIndex] then
    begin
      lbxRenderingOrder.Items.Append(lbxFileBox.Items[lbxFileBox.ItemIndex]);
      fSelectedFilesList.Append(fFileList.Strings[lbxFileBox.ItemIndex]);
    end
  else
    begin
      i := lbxRenderingOrder.Items.Count - 1;
      repeat
        if (lbxFileBox.Items[lbxFileBox.ItemIndex] = lbxRenderingOrder.Items[i]) then
          begin
            lbxRenderingOrder.DeleteString(i);
            fSelectedFilesList.Delete(i);
          end;
        Dec(i);
      until (i < 0);
    end;
end;


procedure TDemoWMFMain.lbxFileBoxDblClick(Sender: TObject);
begin
  bDblClick := True;
  // Add a duplicate
  if lbxFileBox.Checked[lbxFileBox.ItemIndex] then
    begin
      lbxRenderingOrder.Items.Append(lbxFileBox.Items[lbxFileBox.ItemIndex]);
      fSelectedFilesList.Append(fFileList.Strings[lbxFileBox.ItemIndex]);
    end
end;


procedure TDemoWMFMain.lbxRenderingOrderClick(Sender: TObject);
var
  i: Integer;

begin
  // Show a preview of the selected imagefile.
  for i := 0 to fFileList.Count - 1 do
    begin
      if EndsText(lbxRenderingOrder.Items[lbxRenderingOrder.ItemIndex],
                  fFileList.Strings[i]) then
        begin
          imgPreview.Picture.LoadFromFile(fFileList.Strings[i]);
          Break;
        end;
    end;
end;


procedure TDemoWMFMain.lbxRenderingOrderDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  TargetPos: Integer;
  i, j: Integer;

begin

 TargetPos := lbxRenderingOrder.itemAtPos(Point(X,Y), False);

 if (TargetPos >= 0) and (TargetPos < lbxRenderingOrder.Count) then
   begin
     lbxRenderingOrder.Items.Move(iSourcePos,
                                  TargetPos);
     lbxRenderingOrder.ItemIndex := TargetPos;

     // Clear and update the fSelectedFilesList.
     fSelectedFilesList.Clear;
     for i := 0 to lbxRenderingOrder.Count - 1 do
       begin   //fFileList
         for j := 0 to fFileList.Count - 1 do
           begin
             if EndsText(lbxRenderingOrder.Items[i],
                         fFileList.Strings[j]) then
               fSelectedFilesList.Append(fFileList.Strings[j]);
           end;
       end;
   end;
end;


procedure TDemoWMFMain.lbxRenderingOrderDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := True;
end;


procedure TDemoWMFMain.lbxRenderingOrderStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  iSourcePos := lbxRenderingOrder.ItemIndex;
end;


function TDemoWMFMain.GetSelectedFiles(): Integer;
var
  i: Integer;
  n: Integer;

begin
  n := 0;
  for i := 0 to lbxFileBox.Items.Count -1 do
    if lbxFileBox.Checked[i] then
      Inc(n);
  Result := n;
end;


procedure TDemoWMFMain.DoUpdate(var msg: TMessage);
begin
  stbStatus.SimpleText := Format('Image %d',
                                 [(msg.WParam + 1)]);
  stbStatus.Repaint();
end;


// Play the result with the system default app.
procedure TDemoWMFMain.edLocationDblClick(Sender: TObject);
begin
  if FileExists(edLocation.Text) then
    begin
      ShellExecute(Handle,
                   'open',
                   PWideChar(edLocation.Text),
                   nil,
                   nil,
                   SW_SHOWNORMAL);
    end;
end;


procedure TDemoWMFMain.cbxFileExtChange(Sender: TObject);
var
  i: Integer;

begin
  fCodecList := GetSupportedCodecs(cbxFileExt.Items[cbxFileExt.ItemIndex]);
  cbxCodecs.Clear();

  for i := 0 to Length(fCodecList) - 1 do
    cbxCodecs.Items.Add(CodecNames[fCodecList[i]]);

  cbxCodecs.ItemIndex := 0;
  cbxCodecsChange(nil);
end;


procedure TDemoWMFMain.cbxFrameRatesChange(Sender: TObject);
begin
  SetFrameRate();
end;


procedure TDemoWMFMain.FormCreate(Sender: TObject);
var
  i: Integer;
  //localArrayAudio: array of TMFAudioFormat;

begin
  fDirectoryTree := TDirectoryTree.Create(self);
  fDirectoryTree.Parent := Panel3;
  fDirectoryTree.Align := alClient;
  fDirectoryTree.Images := ImageList1;
  fDirectoryTree.HideSelection := False;
  fFileList := TStringlist.Create;
  fSelectedFilesList := TStringlist.Create;
  fDirectoryTree.NewRootFolder(TPath.GetPicturesPath);
  fOutputFile := GetDesktopFolder + '\Example';
  fCodecList := GetSupportedCodecs('.mp4');

  for i := 0 to Length(fCodecList) - 1 do
    cbxCodecs.Items.Add(CodecNames[fCodecList[i]]);

  cbxCodecs.ItemIndex := 0;
  fDirectoryTree.OnChange := DirectoryTreeChange;
  fVideoStandardsCheat := TVideoStandardsCheat.Create();
  GetResolutions();
  GetFrameRates();

  fFramebm := TBitmap.Create();
  FrameBox.ControlStyle := FrameBox.ControlStyle + [csOpaque];
  mnuNewClick(Self);
  // Info labels
  lblCombinedMovieInfo.Caption := 'Demo for inserting a video-clip into the series of bitmaps to be encoded.' + #13 +
                                  'Only the video -stream will be inserted, the audio-file plays while the video is shown.' + #13 +
                                  'If you pick the video again as audio-file, the video-audio gets encoded.' + #13 +
                                  'You can optionally make a crossfade transition from the last bitmap-frame added to the first video-frame.' + #13 +
                                  'See TBitmapEncoderWMF.AddVideo.' + #13 +
                                  'By default the following video formats/containers are supported by Windows.' + #13 +
                                  '' +
                                  'The decoder needs to be installed in Windows.';
  // TEST
  // Load AAC profiles
  //fAudioMft := TAudioMft.Create();
  //fAudioMft.GetAudioFormats(MFAudioFormat_AAC,
  //                          MFT_ENUM_FLAG_ALL);
  //SetLength(localArrayAudio, 3);
  //localArrayAudio[0] := fAudioMft.AudioFormats[0];

  lbxFileBox.MultiSelect := True;
  bDblClick := False;
  spedEffectDuration.Value := 4000;
  Randomize();
end;


procedure TDemoWMFMain.FormDestroy(Sender: TObject);
begin
  fFileList.Free();
  fSelectedFilesList.Free();
  fFramebm.Free();
  fVideoStandardsCheat.Free();
  fAudioMft.Free();
end;


procedure TDemoWMFMain.FrameBoxPaint(Sender: TObject);
begin
  BitBlt(FrameBox.Canvas.Handle,
         0,
         0,
         fFramebm.Width,
         fFramebm.Height,
         fFramebm.Canvas.Handle,
         0,
         0,
         SRCCopy);
end;


procedure TDemoWMFMain.FrameNoChange(Sender: TObject);
begin
  if FileExists(VideoClipFile.Caption) then
    begin
      if GetFrameBitmap(VideoClipFile.Caption,
                        fFramebm,
                        FrameBox.Height,
                        FrameNo.Value) then
        begin
          FrameBox.Width := fFramebm.Width;
          FrameBox.Invalidate;
        end;
    end;
end;


function TDemoWMFMain.GetAudioBitRate(): Double;
begin
  Result := (fSelectedAudioFormat.unAvgBytesPerSec  * 8) / 1000;
end;


function TDemoWMFMain.GetAudioDialog(): Boolean;
begin
  Result := chkAddAudio.Checked;
end;


function TDemoWMFMain.GetAudioFile(): string;
begin
  Result := '';
  FODAudio.FileName := '';
  if not FODAudio.Execute(Handle) then
    Exit;

  Result := FODAudio.FileName;
end;


function TDemoWMFMain.GetAudioSampleRate(): Double;
begin
  Result := fSelectedAudioFormat.unSamplesPerSec / 1000;
end;


function TDemoWMFMain.GetAudioStart(): Int64;
begin
  Result := spedAudioStartTime.Value;
end;


function TDemoWMFMain.GetDoCrop(): Boolean;
begin
  Result := chkCropLandscape.Checked;
end;


function TDemoWMFMain.GetDoZoomInOut(): Boolean;
begin
  Result := chkZoomInOut.Checked;
end;


procedure TDemoWMFMain.GetResolutions();
var
  i: Integer;

begin
  cbxResolution.Clear();
  // Get all resolutions.
  fVideoStandardsCheat.GetResolutions();
  for i := 0 to Length(fVideoStandardsCheat.Resolutions) -1 do
    cbxResolution.Items.Append(Format('%s (%d x %d) Aspect Ratio: %s', [fVideoStandardsCheat.Resolutions[i].Resolution,
                                                                        fVideoStandardsCheat.Resolutions[i].iWidth,
                                                                        fVideoStandardsCheat.Resolutions[i].iHeight,
                                                                        fVideoStandardsCheat.Resolutions[i].StrAspectRatio]));
  // Default resolution and aspect ratio.
  cbxResolution.ItemIndex := 50; // 4K 16:9
  SetResolution();
end;


procedure TDemoWMFMain.mnuImageSlideshowClick(Sender: TObject);
begin
  pnlSlideShow.BringToFront;
  DirectoryTreeChange(fDirectoryTree,
                      fDirectoryTree.Selected);
end;

procedure TDemoWMFMain.GetFramerates();
var
  i: Integer;
begin
  cbxFrameRates.Clear();
  fVideoStandardsCheat.GetFrameRates();
  for i := 0 to Length(fVideoStandardsCheat.FrameRates) -1 do
    cbxFrameRates.Items.Append(string(fVideoStandardsCheat.FrameRates[i].sFrameRate));
  cbxFrameRates.ItemIndex := 14 // 60 fps
end;


function TDemoWMFMain.SetFrameRate(): Double;
begin
  fVideoStandardsCheat.CurrentFrameRate := cbxFrameRates.ItemIndex;
  cbxFrameRates.Hint := string(fVideoStandardsCheat.FrameRates[fVideoStandardsCheat.CurrentFrameRate].sHint);
  Result := fVideoStandardsCheat.FrameRates[fVideoStandardsCheat.CurrentFrameRate].FrameRate;
end;



function TDemoWMFMain.GetOutputFileName(): string;
begin
  Result := Format('%s_%s%s',
                   [fOutputFile,
                    CodecShortNames[fCodecList[cbxCodecs.ItemIndex]],
                    cbxFileExt.Text]);
end;


function TDemoWMFMain.GetQuality(): Integer;
begin
  Result := spedSetQuality.Value;
end;


procedure TDemoWMFMain.cbxResolutionChange(Sender: TObject);
begin
  SetResolution();
  Preview.Invalidate();
end;


procedure TDemoWMFMain.chkAddAudioClick(Sender: TObject);
begin
  cbxAudioCodec.Enabled := chkAddAudio.Checked;
  spedAudioStartTime.Enabled := chkAddAudio.Checked;
end;


procedure TDemoWMFMain.SetResolution();
begin
  // store current resolution
  fVideoStandardsCheat.CurrentResolution := cbxResolution.ItemIndex;
  iVideoWidth := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].iWidth;
  iVideoHeight := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].iHeight;
  fAspectRatio := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].AspectRatio;
end;


procedure TDemoWMFMain.PickEndImageClick(Sender: TObject);
begin
  if not FODPic.Execute() then
    Exit;

  EndImageFile.Caption := FODPic.FileName;
end;


procedure TDemoWMFMain.PickStartImageClick(Sender: TObject);
begin
  if not FODPic.Execute() then
    Exit;

  StartImageFile.Caption := FODPic.FileName;
end;


procedure TDemoWMFMain.PickVideoClick(Sender: TObject);
var
  VideoInfo: TVideoInfo;

begin
  if not FODVideo.Execute then
    Exit;

  try

    VideoInfo := GetVideoInfo(FODVideo.FileName);

  except
    ShowMessage(Format('Video format of %s is not supported',
                       [ExtractFileName(FODVideo.FileName)]));
    Exit;
  end;

  VideoClipFile.Caption := FODVideo.FileName;
  DisplayVideoInfo(Memo1,
                   VideoInfo);

  if GetFrameBitmap(FODVideo.FileName,
                    fFramebm,
                    FrameBox.Height,
                    FrameNo.Value) then
    begin
      FrameBox.Width := fFramebm.Width;
      FrameBox.Invalidate();
    end;
end;


procedure TDemoWMFMain.pnlVideoFromImagesClick(Sender: TObject);
begin
 pnlCombinedVideo.BringToFront();
end;


procedure TDemoWMFMain.mnuNewClick(Sender: TObject);
begin
  pnlSettings.BringToFront;
  mnuPlay.Enabled := False;
  cbxFileExt.ItemIndex := 0;
  cbxFileExt.OnChange(Self);
end;


procedure TDemoWMFMain.mnuPlayClick(Sender: TObject);
begin
  if not fWriting then
    if FileExists(OutputFileName) then
      ShellExecute(Handle,
                   'open',
                   PWideChar(OutputFileName),
                   nil,
                   nil,
                   SW_SHOWNORMAL);
end;


procedure TDemoWMFMain.DisplayVideoInfo(const aMemo: TMemo;
                                        const VideoInfo: TVideoInfo);
begin
  aMemo.Clear();

  aMemo.Lines.Add('Codec name: ' + VideoInfo.CodecName);

  aMemo.Lines.Add(Format('Video size: %d x %d',
                         [VideoInfo.VideoWidth,
                          VideoInfo.VideoHeight]));

  aMemo.Lines.Add(Format('Frame rate: %s fps',
                         [FloatToStrF(VideoInfo.FrameRate,
                                      ffFixed,
                                      4,
                                      2)]));

  aMemo.Lines.Add(Format('Duration: %s sec',
                         [FloatToStrF(VideoInfo.Duration / 1000 / 10000,
                                      ffFixed,
                                      5,
                                      2)]));

  aMemo.Lines.Add(Format('Pixel aspect ratio: %s',
                         [FloatToStrF(VideoInfo.PixelAspect,
                                      ffFixed,
                                      5,
                                      4)]));

  aMemo.Lines.Add(Format('Interlace mode: %s (%d)',
                         [VideoInfo.InterlaceModeName,
                          VideoInfo.InterlaceMode]));

  aMemo.Lines.Add(Format('Audio streams: %d',
                         [VideoInfo.AudioStreamCount]));
end;


procedure TDemoWMFMain.PreviewPaint(Sender: TObject);
begin
  Preview.Width := Round(Preview.Height * Aspect);
  Preview.Canvas.Brush.Color := clMaroon;
  Preview.Canvas.Fillrect(Preview.ClientRect);
end;


procedure TDemoWMFMain.mnuTranscodeClick(Sender: TObject);
begin
  pnlTranscoder.BringToFront;
end;


{ TListBox }

procedure TListBox.CNCommand(var AMessage: TWMCommand);
begin
  inherited;
  if (AMessage.NotifyCode = LBN_SELCHANGE) then
    begin
      if Assigned(fOnSelChange) then
        fOnSelChange(Self);
  end;
end;

initialization

  ReportMemoryLeaksOnShutDown := True;

end.
