unit uDemoWMFMain;

interface

uses
  {Winapi}
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  Winapi.ShellAPI,
  Winapi.ShlObj,

  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Math,
  {$IF COMPILERVERSION > 28.0}
  System.ImageList,
  {$ENDIF} // Delphi version XE4 or higher.
  {System}
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
  // Needed by TImage
  VCL.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  // ================
  {MediaFoundation}
  WinApi.MediaFoundation.VideoStandardsCheat,
  {Application}
  uDirectoryTree,
  uScaleWMF,
  uScaleCommonWMF,
  uToolsWMF,
  uBitMaps2VideoWMF,
  uTransformer;

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
    SettingsPanel: TPanel;
    PagesPanel: TPanel;
    StatusPanel: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    WriteAnimation: TButton;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Status: TLabel;
    Splitter1: TSplitter;
    cbxFileExt: TComboBox;
    cbxCodecs: TComboBox;
    Splitter2: TSplitter;
    Panel4: TPanel;
    Panel5: TPanel;
    butWriteSlideshow: TButton;
    chkBackground: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cbxResolution: TComboBox;
    ImageCount: TLabel;
    Preview: TPaintBox;
    lblCodecInfo: TLabel;
    Label1: TLabel;
    spedSetQuality: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    cbxFrameRates: TComboBox;
    chkCropLandscape: TCheckBox;
    OutputInfo: TLabel;
    butShowVideo: TButton;
    chkZoomInOut: TCheckBox;
    Label9: TLabel;
    FODAudio: TFileOpenDialog;
    Button2: TButton;
    OD: TFileOpenDialog;
    chkDebugTiming: TCheckBox;
    cbxAudioSampleRate: TComboBox;
    cbxAudioBitrate: TComboBox;
    Label7: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    spedAudioStartTime: TSpinEdit;
    Label12: TLabel;
    chkAddAudio: TCheckBox;
    Label8: TLabel;
    Panel6: TPanel;
    lbxFileBox: TListBox;
    Splitter3: TSplitter;
    TabSheet3: TTabSheet;
    PickStartImage: TButton;
    PickEndImage: TButton;
    PickVideo: TButton;
    FODPic: TFileOpenDialog;
    FODVideo: TFileOpenDialog;
    StartImageFile: TLabel;
    EndImageFile: TLabel;
    VideoClipFile: TLabel;
    CombineToVideo: TButton;
    PickAudio: TButton;
    AudioFileName: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Memo1: TMemo;
    FrameNo: TSpinEdit;
    FrameBox: TPaintBox;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    TabSheet4: TTabSheet;
    Button1: TButton;
    TranscoderInput: TLabel;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    Label19: TLabel;
    Button4: TButton;
    ImageList1: TImageList;
    imgPreview: TImage;
    Bevel1: TBevel;
    Bevel2: TBevel;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure WriteAnimationClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure butWriteSlideshowClick(Sender: TObject);
    procedure cbxFileExtChange(Sender: TObject);
    procedure cbxCodecsChange(Sender: TObject);
    procedure cbxResolutionChange(Sender: TObject);
    procedure PreviewPaint(Sender: TObject);
    procedure butShowVideoClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
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
    procedure lbxFileBoxClick(Sender: TObject);
    procedure cbxFrameRatesChange(Sender: TObject);

  private
    { Private-Declarations }
    fDirectoryTree: TDirectoryTree;
    fFileList: TStringlist;
    fOutputFile: string;
    fCodecList: TCodecIdArray;
    fVideoStandardsCheat: TVideoStandardsCheat;
    fWriting: Boolean;
    fFramebm: TBitmap;
    fUserAbort: Boolean;
    fAspectRatio: Double;
    iVideoWidth: Integer;
    iVideoHeight: Integer;

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
    function GetAudioBitRate(): Integer;
    function GetAudioSampleRate(): Integer;
    function GetAudioStart(): Int64;
    function GetAudioDialog(): Boolean;
    procedure lbxFileBoxSelChange(Sender: TObject);
    procedure TransCodeProgress(Sender: TObject;
                                FrameCount: Cardinal;
                                VideoTime: Int64;
                                var DoAbort: Boolean);
    procedure DisplayVideoInfo(const aMemo: TMemo;
                               const VideoInfo: TVideoInfo);

  public
    { Public-Declarations }
    // properties which read the input parameters for the bitmap-encoder
    // off the controls of the form
    property OutputFileName: string read GetOutputFileName;
    property Aspect: Double read fAspectRatio;
    property VideoHeight: Integer read iVideoHeight;
    property VideoWidth: Integer read iVideoWidth;
    property FrameRate: Double read SetFrameRate;
    property Quality: Integer read GetQuality;
    property DoCrop: Boolean read GetDoCrop;
    property DoZoomInOut: Boolean read GetDoZoomInOut;
    property AudioFile: string read GetAudioFile;
    property AudioSampleRate: Integer read GetAudioSampleRate;
    property AudioBitRate: Integer read GetAudioBitRate;
    property AudioStart: Int64 read GetAudioStart;
    property AudioDialog: Boolean read GetAudioDialog;

  end;

var
  DemoWMFMain: TDemoWMFMain;

implementation

{$R *.dfm}


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
  if Succeeded(SHGetSpecialFolderLocation(0, $0000, FolderPidl)) then
  begin
    Result := PIDLToPath(FolderPidl);
    PidlFree(FolderPidl);
  end
  else
    Result := '';
end;


procedure TDemoWMFMain.WriteAnimationClick(Sender: TObject);
var
  i, j, w, h: Integer;
  A, r, theta, dtheta: Double;
  xCenter, yCenter: Integer;
  scale: Double;
  bm, pre: TBitmap;
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
    Preview.Width := round(Aspect * Preview.Height);
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
                     cfBicubic);

      bm := TBitmap.Create();

      try
        // AntiAlias 2*Video-Height
        bm.SetSize(2 * w, 2 * h);
        xCenter := bm.Width div 2;
        yCenter := bm.Height div 2;
        scale := bm.Height / 4;

        bm.Canvas.brush.color := clMaroon;
        bm.Canvas.pen.color := clYellow;
        bm.Canvas.pen.Width := Max(h div 180,
                               2);

        dtheta := 2 / 150 * Pi;
        StopWatch.Start;

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
                points[j] := map(Pointf(r * cos(theta), r * sin(theta)));
                theta := theta + dtheta;
              end;

          bm.Canvas.Fillrect(bm.Canvas.clipRect);
          bm.Canvas.PolyLine(points);

          bme.AddFrame(bm,
                       False);

          Status.Caption := Format('Frame %d',
                                   [(i + 1)]);
          Status.Repaint;

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
        StopWatch.Stop;
        Status.Caption := Format('%s %s %s',
                                 ['Writing speed including drawing to canvas:',
                                  FloatToStrF(bme.FrameCount * 1000 / StopWatch.ElapsedMilliseconds,
                                              ffFixed,
                                              5,
                                              2),
                                  'fps']);
      finally
        bm.Free();
      end;
      bme.Finalize;

    finally
      bme.Free;
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
  const wic: TWicImage; const bm: TBitmap; const bme: TBitmapEncoderWMF;
  var Done: Boolean; threaded: Boolean);
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
  WicToBmp(wic, bm);
  crop := (bm.Width > bm.Height) and DoCrop;
  bme.AddStillImage(bm, 4000, crop);
  PostMessage(Handle, MsgUpdate, 0, 0);
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

      bme.CrossFadeTo(bm, 2000, crop)

    else
    begin
      Zooms := GetRandomZoom;
      Zoom := GetRandomZoom;

      bme.ZoomInOutTransitionTo(bm, Zooms, Zoom, 2500, crop);

    end;

    bme.AddStillImage(bm, 4000, crop);
    PostMessage(Handle, MsgUpdate, i, 0);
    if not threaded then
      Application.ProcessMessages;
  end;
  Done := True;
end;


procedure TDemoWMFMain.butShowVideoClick(Sender: TObject);
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
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;

  af := '';

  if AudioDialog then
    af := AudioFile;

  fWriting := True;

  // Use a local stringlist because of threading
  sl := TStringlist.Create();

  try
    for i := 0 to fFileList.Count - 1 do
      if lbxFileBox.Selected[i] then
        sl.Add(fFileList.Strings[i]);

    if (sl.Count = 0) then
      begin
        ShowMessage('No image files selected');
        Exit;
      end;

    bme := TBitmapEncoderWMF.Create();
    bm := TBitmap.Create();
    wic := TWicImage.Create();
    StopWatch := TStopWatch.Create();

    try
      Status.Caption := 'Working';
      StopWatch.Start();

      // bms.PixelFormat := pf32bit;
      // bms.SetSize(VideoWidth, VideoHeight);
      // BitBlt(bms.Canvas.Handle, 0, 0, VideoWidth, VideoHeight, 0, 0, 0,
      // BLACKNESS);

      try
        bme.Initialize(OutputFileName,
                       VideoWidth,
                       VideoHeight,
                       Quality,
                       FrameRate,
                       fCodecList[cbxCodecs.ItemIndex],
                       cfBicubic,
                       af,
                       AudioBitRate,
                       AudioSampleRate,
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
              Application.ProcessMessages();
              sleep(100);
            end;

          task.Wait();
          Application.ProcessMessages();
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

      Status.Caption := Format('%s: %s %s %s',
                               ['Rendering finished',
                                'Writing speed including decoding of image files and computing transitions:',
                                FloatToStrF(1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds,
                                            ffFixed,
                                            5,
                                            2),
                                'fps']);
      Status.Repaint();

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
        ShowMessage('Pick valid files for the images and the video clip first.' +
        'The output filename cannot be identical to the video clip name.');
        Exit;
    end;

    StopWatch := TStopWatch.Create();
    bme := TBitmapEncoderWMF.Create();

    try

      StopWatch.Start();
      Status.Caption := 'Working';

      try
        bme.Initialize(OutputFileName,
                       VideoWidth,
                       VideoHeight,
                       Quality,
                       FrameRate,
                       TCodecID(cbxCodecs.ItemIndex),
                       cfBicubic,
                       af,
                       128,
                       44100,
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

        Status.Caption := 'Start Image';
        bme.AddStillImage(bm,
                          5000,
                          False);

        Status.Caption := 'Video Clip';

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
        Status.Caption := 'End Image';

        bme.CrossFadeTo(bm,
                        4000,
                        False);

        bme.AddStillImage(bm,
                          5000,
                          False);

      finally
        bm.Free();
        wic.Free();
      end;

      StopWatch.Stop();

      fps := 1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds;

    finally
      // destroy finalizes
      bme.Free();
    end;

    Status.Caption := 'Writing speed: ' +
                      FloatToStrF(fps,
                                  ffFixed,
                                  5,
                                  2) + ' fps';
  finally
    fWriting := False;
  end;
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
    ShowMessage('Format of input file not supported');
  end;
  DisplayVideoInfo(Memo2, VideoInfo);
end;


procedure TDemoWMFMain.Button2Click(Sender: TObject);
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
  min, sec: Integer;

begin
  sec := VideoTime div 1000;
  min := sec div 60;
  sec := sec mod 60;

  Status.Caption := Format('%s %d %s %d',
                           ['Encoding time-stamp:',
                            min,
                            ':',
                            sec]);

  Status.Invalidate();
  Application.ProcessMessages();
  DoAbort := fUserAbort;
end;


procedure TDemoWMFMain.Button3Click(Sender: TObject);
begin
  if fWriting then
    begin
      ShowMessage('Encoding in progress, wait until finished.');
      Exit;
    end;

  fWriting := True;

  try

    Status.Caption := 'Working, please wait';
    fUserAbort := False;
    TranscodeVideoFile(TranscoderInput.Caption,
                       OutputFileName,
                       TCodecID(cbxCodecs.ItemIndex),
                       Quality,
                       VideoWidth,
                       VideoHeight,
                       FrameRate,
                       CheckBox1.Checked,
                       TransCodeProgress);

    if fUserAbort then
      Status.Caption := 'Aborted'
    else
      Status.Caption := 'Done';

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
  OutputInfo.Caption := 'Output will be saved to ' + OutputFileName;
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

  lbxFileBox.SelectAll();
  lbxFileBoxSelChange(nil);
end;


procedure TDemoWMFMain.lbxFileBoxClick(Sender: TObject);
begin
  // show selected image.
  imgPreview.Picture.LoadFromFile(fFileList.Strings[lbxFileBox.ItemIndex]);
  //lbxFileBox.Items[lbxFileBox.ItemIndex];
end;


procedure TDemoWMFMain.lbxFileBoxSelChange(Sender: TObject);
begin
  ImageCount.Caption := Format('%d %s',
                               [lbxFileBox.SelCount,
                                'images selected (bmp, jpg, png, gif)']);
end;


procedure TDemoWMFMain.DoUpdate(var msg: TMessage);
begin
  Status.Caption := Format('%s %d',
                           ['Image',
                            (msg.WParam + 1)]);
  Status.Repaint();
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

begin
  fDirectoryTree := TDirectoryTree.Create(self);
  fDirectoryTree.Parent := Panel3;
  fDirectoryTree.Align := alClient;
  fDirectoryTree.Images := ImageList1;
  fDirectoryTree.HideSelection := False;
  fFileList := TStringlist.Create;
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
  lbxFileBox.OnSelChange := lbxFileBoxSelChange;
  fFramebm := TBitmap.Create();
  FrameBox.ControlStyle := FrameBox.ControlStyle + [csOpaque];
  Randomize();
end;


procedure TDemoWMFMain.FormDestroy(Sender: TObject);
begin
  fFileList.Free();
  fFramebm.Free();
  fVideoStandardsCheat.Free();
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


function TDemoWMFMain.GetAudioBitRate(): Integer;
begin
  Result := StrToInt(cbxAudioBitrate.Text);
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


function TDemoWMFMain.GetAudioSampleRate(): Integer;
begin
  Result := StrToInt(cbxAudioSampleRate.Text);
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
    cbxResolution.Items.Append(Format('%s (%d x %d) AspectRatio: %s', [fVideoStandardsCheat.Resolutions[i].Resolution,
                                                                       fVideoStandardsCheat.Resolutions[i].iWidth,
                                                                       fVideoStandardsCheat.Resolutions[i].iHeight,
                                                                       fVideoStandardsCheat.Resolutions[i].StrAspectRatio]));
  // Default resolution and aspect ratio.
  cbxResolution.ItemIndex := 50; // 4K 16:9
  SetResolution();
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


procedure TDemoWMFMain.SetResolution();
begin
  // store current resolution
  fVideoStandardsCheat.CurrentResolution := cbxResolution.ItemIndex;
  iVideoWidth := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].iWidth;
  iVideoHeight := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].iHeight;
  fAspectRatio := fVideoStandardsCheat.Resolutions[fVideoStandardsCheat.CurrentResolution].AspectRatio;
end;


procedure TDemoWMFMain.PageControl1Change(Sender: TObject);
begin
  if (PageControl1.TabIndex = 1) then
    DirectoryTreeChange(fDirectoryTree,
                        fDirectoryTree.Selected);
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
