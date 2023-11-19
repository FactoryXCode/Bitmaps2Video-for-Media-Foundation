// ==============================================================================
//
// LICENSE
//
// The contents of this file are subject to the Mozilla Public License
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/en-US/MPL/2.0/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// Non commercial users may distribute this sourcecode provided that this
// header is included in full at the top of the file.
// Commercial users are not allowed to distribute this sourcecode as part of
// their product.
//
// ==============================================================================
// Copyright © 2023 Renate Schaaf
//
// Requires MFPack at https://github.com/FactoryXCode/MfPack
// Download the repository and add the folder "src" to your library path.
//
// The sinkwriter sample in this repository got me started on this project.
// Thanks for the great work!
// ==============================================================================
unit uTransformer;

// Contains:
// TVideoTransformer:
// transforms video samples to uncompressed RGB32-samples with pixel-aspect
// 1x1, optionally changing the frame height (width by aspect), and the frame rate.
// Designed to de-interlace interlaced videos, but not sure whether it really works.

// Planned addition:
// TAudioTransformer doing the analogous for audio samples.

interface

{$IFOPT O+ }
{$DEFINE O_PLUS }
{$O- }
{$ENDIF }

uses
  {WinApi}
  WinApi.Windows,
  WinApi.ActiveX,
  {System}
  System.SysUtils,
  System.Types,
  System.Math,
  System.Classes,
  {VCL}
  VCL.Graphics,
  {MediaFoundationApi}
  WinApi.MediaFoundationApi.MfApi,
  WinApi.MediaFoundationApi.MfUtils,
  WinApi.MediaFoundationApi.MfReadWrite,
  WinApi.MediaFoundationApi.Mfobjects,
  WinApi.MediaFoundationApi.CodecApi,
  WinApi.ActiveX.PropIdl,
  WinApi.MediaFoundationApi.MfIdl,
  WinApi.ActiveX.PropVarUtil;

type

  TVideoInfo = record
    Codec: TGUID;
    CodecName: string;
    Duration: Int64;
    VideoWidth, VideoHeight: DWord;
    FrameRate: Single;
    PixelAspect: Single;
    InterlaceMode: DWord;
    InterlaceModeName: string;
    AudioStreamCount: DWord;
  end;

  eVideoFormatException = class(Exception);

  TVideoTransformer = class
  private
    pReader: IMFSourceReader;
    hrCoInit: HResult;
    fVideoInfo: TVideoInfo;
    pMediaTypeOut: IMFMediaType;
    fNewWidth, fNewHeight: DWord;
    fNewFrameRate: Single;
    fInputFile: string;
    fEndOfFile: Boolean;

  public
    constructor Create(const InputFile: string;
                       NewHeight: DWord;
                       NewFrameRate: Single);

    procedure NextValidSampleToBitmap(const bm: TBitmap;
                                      out Timestamp: Int64;
                                      out Duration: Int64);

    procedure GetNextValidSample(out pSample: IMFSample;
                                 out Timestamp: Int64;
                                 out Duration: Int64);

    destructor Destroy(); override;

    property NewVideoWidth: DWord read fNewWidth;
    property NewVideoHeight: DWord read fNewHeight;
    property NewFrameRate: Single read fNewFrameRate;
    property EndOfFile: Boolean read fEndOfFile;
    property VideoInfo: TVideoInfo read fVideoInfo;
  end;

function GetVideoInfo(const VideoFileName: string): TVideoInfo;

// Very slow at the moment. Need to apply seeking to speed it up.
function GetFrameBitmap(const VideoFileName: string;
                        const bm: TBitmap;
                        bmHeight: DWord;
                        FrameNo: DWord): Boolean;

implementation

function GetVideoInfo(const VideoFileName: string): TVideoInfo;
var
  Count: Integer;
  GUID: TGUID;
  _var: TPropVariant;
  Num, Den: DWord;
  pReader: IMFSourceReader;
  pMediaTypeIn, pMediaTypeOut, pPartialType: IMFMediaType;
  mfArea: MFVideoArea;
  attribs: IMFAttributes;
  hrCoInit, hrStartup: HResult;
  pb: PByte;
  FourCC: DWord;
  FourCCString: string[4];
  I: Integer;
  hr: HResult;
  err: string;
  AudioStreamNo: DWord;

const
  ProcName = 'GetVideoInfo';

  procedure CheckFail(hr: HResult);
    begin
      inc(Count);
      if not SUCCEEDED(hr) then
        begin
          err := '$' + IntToHex(hr, 8);
          raise Exception.CreateFmt('%s %d %s %s %S %s',
                                    ['Fail in call nr.',
                                     Count,
                                     'of',
                                     ProcName,
                                     'with result',
                                     err]);
        end;
    end;

begin
  Count := 0;
  pReader := nil;
  hrCoInit := E_FAIL;
  hrStartup := E_FAIL;

  try
    hrCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    CheckFail(hrCoInit);

    hrStartup := MFStartup(MF_VERSION);
    CheckFail(hrStartup);

    CheckFail(MFCreateAttributes(attribs,
                                 1));
    CheckFail(attribs.SetUInt32(MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING,
                                UInt32(True)));

    // Create a sourcereader for the video file
    CheckFail(MFCreateSourceReaderFromURL(PWideChar(VideoFileName),
                                          attribs,
                                          pReader));

    // Configure the sourcereader to decode to RGB32
    CheckFail(pReader.GetNativeMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                         0,
                                         pMediaTypeIn));

    CheckFail(MFCreateMediaType(pPartialType));

    CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE,
                                   MFMediaType_Video));

    CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE,
                                   MFVideoFormat_RGB32));

    CheckFail(pReader.SetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                          0,
                                          pPartialType));

    CheckFail(pReader.GetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                          pMediaTypeOut));

    CheckFail(pMediaTypeIn.GetMajorType(GUID));

    CheckFail(pMediaTypeIn.GetGUID(MF_MT_SUBTYPE,
                                   GUID));

    Result.Codec := GUID;

    if (GUID = MFVideoFormat_MPEG2) then
      Result.CodecName := 'mpeg2'
    else
      begin
        FourCC := GUID.D1;
        pb := PByte(@FourCC);
        SetLength(FourCCString,
                  4);
        for I := 1 to 4 do
          begin
            FourCCString[I] := AnsiChar(pb^);
            inc(pb);
          end;
        Result.CodecName := string(FourCCString);
      end;

    PropVariantInit(_var);

    CheckFail(pReader.GetPresentationAttribute(MF_SOURCE_READER_MEDIASOURCE,
                                               MF_PD_DURATION,
                                               _var));

    CheckFail(PropVariantToInt64(_var,
                                 Result.Duration));

    // Result.Duration := _var.hVal.QuadPart; Makes no difference.
    PropVariantClear(_var);

    ZeroMemory(@mfArea, SizeOf(mfArea));

    // for some codecs, like HEVC, MF_MT_FRAME_SIZE does not
    // return the correct video size for display.
    // So we check first whether the correct size is
    // available via an MFVideoArea.
    hr := pMediaTypeIn.GetBlob(MF_MT_PAN_SCAN_APERTURE,
                               @mfArea,
                               SizeOf(MFVideoArea),
                               nil);

    if FAILED(hr) then
      hr := pMediaTypeIn.GetBlob(MF_MT_MINIMUM_DISPLAY_APERTURE,
                                 @mfArea,
                                 SizeOf(MFVideoArea),
                                 nil);

    if SUCCEEDED(hr) then
      begin
        Result.VideoWidth := mfArea.Area.cx;
        Result.VideoHeight := mfArea.Area.cy;
      end
    else
      CheckFail(MFGetAttributeSize(pMediaTypeIn,
                                   MF_MT_FRAME_SIZE,
                                   Result.VideoWidth,
                                   Result.VideoHeight));

    CheckFail(MFGetAttributeRatio(pMediaTypeIn,
                                  MF_MT_FRAME_RATE,
                                  Num,
                                  Den));

    Result.FrameRate := Num / Den;

    // For some codecs it only reads the correct pixel aspect off the decoding media type
    hr := MFGetAttributeRatio(pMediaTypeOut,
                              MF_MT_PIXEL_ASPECT_RATIO,
                              Num,
                              Den);

    if FAILED(hr) then // MF_E_PROPERTY_TYPE_NOT_ALLOWED
      CheckFail(MFGetAttributeRatio(pMediaTypeIn,
                                    MF_MT_PIXEL_ASPECT_RATIO,
                                    Num,
                                    Den));

    Result.PixelAspect := Num / Den;

    hr := pMediaTypeIn.GetUInt32(MF_MT_INTERLACE_MODE,
                                 Result.InterlaceMode);

    if FAILED(hr) then
      Result.InterlaceMode := 0;

    case Result.InterlaceMode of
      0: Result.InterlaceModeName := 'Unknown';
      2: Result.InterlaceModeName := 'Progressive';
      3: Result.InterlaceModeName := 'UpperFirst';
      4: Result.InterlaceModeName := 'LowerFirst';
      5: Result.InterlaceModeName := 'SingleUpper';
      6: Result.InterlaceModeName := 'SingleLower';
      7: Result.InterlaceModeName := 'InterlaceOrProgressive';
    else
      Result.InterlaceModeName := 'Unknown';
    end;

    // Get the nr. of audio-streams
    // Fails for .vob
    Result.AudioStreamCount := 0;
    AudioStreamNo := 0;

    repeat
      hr := pReader.GetNativeMediaType(AudioStreamNo,
                                       0,
                                       pMediaTypeIn);

      if FAILED(hr) then
        begin
          err := IntToHex(hr,
                          8); // MF_E_INVALIDSTREAMNUMBER
          Break;
        end;

      CheckFail(pMediaTypeIn.GetMajorType(GUID));

      if (GUID = MFMediaType_Audio) then
        inc(Result.AudioStreamCount);

      inc(AudioStreamNo);
    until False;

  finally
    if SUCCEEDED(hrStartup) then
      MFShutdown();

    if SUCCEEDED(hrCoInit) then
      CoUninitialize();
  end;
end;


function GetFrameBitmap(const VideoFileName: string;
                        const bm: TBitmap;
                        bmHeight: DWord;
                        FrameNo: DWord): Boolean;
var
  VT: TVideoTransformer;
  FrameCount: DWord;
  pSample: IMFSample;
  Timestamp, Duration: Int64;

begin
  Result := False;
  VT := TVideoTransformer.Create(VideoFileName,
                                 bmHeight,
                                 0);
  try
    FrameCount := 0;

    while (FrameCount + 1 < FrameNo) and (not VT.EndOfFile) do
      begin
        VT.GetNextValidSample(pSample,
                              Timestamp,
                              Duration);
        Inc(FrameCount);
      end;

    if not VT.EndOfFile then
      begin
        VT.NextValidSampleToBitmap(bm,
                                   Timestamp,
                                   Duration);
        Result := True;
      end;

  finally
    VT.Free;
  end;
end;

{ TVideoTransformer }

constructor TVideoTransformer.Create(const InputFile: string;
                                     NewHeight: DWord;
                                     NewFrameRate: Single);
var
  Count: Integer;
  attribs: IMFAttributes;
  pPartialType: IMFMediaType;

const
  ProcName = 'TVideoTransformer.Create';

  procedure CheckFail(hr: HResult);
    begin
      inc(Count);
      if FAILED(hr) then
        begin
          raise Exception.CreateFmt('%s %d %s %s %s %s',
                                    ['Fail in call nr.',
                                    Count,
                                    'of',
                                    ProcName,
                                    'with result',
                                    IntToHex(hr, 8)]);
        end;
    end;

begin
  Count := 0;
  fInputFile := InputFile;
  fNewHeight := NewHeight;

  try
    fVideoInfo := GetVideoInfo(fInputFile);
    if NewFrameRate = 0 then
      fNewFrameRate := fVideoInfo.FrameRate
    else
      fNewFrameRate := NewFrameRate;

    hrCoInit := CoInitializeEx(nil,
                               COINIT_APARTMENTTHREADED);

    CheckFail(hrCoInit);
    CheckFail(MFStartup(MF_VERSION));

    CheckFail(MFCreateAttributes(attribs,
                                 1));

    // Enable the source-reader to make color-conversion, change video size, frame-rate and interlace-mode
    CheckFail(attribs.SetUInt32(MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING,
                                UInt32(True)));

    // The next causes problems for some video formats
    // CheckFail(attribs.SetUInt32
    // (MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, UInt32(True)));
    // Create a sourcereader for the video file
    CheckFail(MFCreateSourceReaderFromURL(PWideChar(fInputFile),
                                          attribs,
                                          pReader));

    // Configure the sourcereader to decode to RGB32
    CheckFail(MFCreateMediaType(pPartialType));

    CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE,
                                   MFMediaType_Video));

    CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE,
                                   MFVideoFormat_RGB32));

    CheckFail(pPartialType.SetUInt32(MF_MT_INTERLACE_MODE,
                                     2));

    // 2 = progressive.
    CheckFail(MFSetAttributeRatio(pPartialType,
                                  MF_MT_FRAME_RATE,
                                  Round(fNewFrameRate * 100),
                                  100));

    fNewWidth := Round(fNewHeight * fVideoInfo.VideoWidth / fVideoInfo.VideoHeight * fVideoInfo.PixelAspect);

    CheckFail(MFSetAttributeRatio(pPartialType,
                                  MF_MT_PIXEL_ASPECT_RATIO,
                                  1,
                                  1));

    CheckFail(MFSetAttributeSize(pPartialType,
                                 MF_MT_FRAME_SIZE,
                                 fNewWidth,
                                 fNewHeight));

    CheckFail(pReader.SetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                          0,
                                          pPartialType));

    CheckFail(pReader.GetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                          pMediaTypeOut));

    // Prevent memory leak
    CheckFail(pReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS,
                                         False));
    // Ensure the stream is selected.
    CheckFail(pReader.SetStreamSelection(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                         True));
    fEndOfFile := False;

  except
    raise eVideoFormatException.Create
      ('Video format of input file not supported.');
  end;
end;


destructor TVideoTransformer.Destroy();
begin
  MFShutdown();
  if SUCCEEDED(hrCoInit) then
    CoUninitialize();
  inherited;
end;


procedure TVideoTransformer.GetNextValidSample(out pSample: IMFSample;
                                               out Timestamp: Int64;
                                               out Duration: Int64);
var
  Count: Integer;
  pSampleLoc: IMFSample;
  Flags: DWord;
  hr: HResult;

const
  ProcName = 'TVideoTransformer.GetNextValidSample';

  procedure CheckFail(hr: HResult);
    begin
      inc(Count);
      if FAILED(hr) then
        begin
          raise Exception.CreateFmt('%s %d %s %s %s %s',
                                    ['Fail in call nr.',
                                    Count,
                                    'of',
                                    ProcName,
                                    'with result',
                                    IntToHex(hr, 8)]);
    end;
  end;

begin
  Count := 0;
  pSample := nil;

  if fEndOfFile then
    Exit;

  repeat
    CheckFail(pReader.ReadSample(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
                                 0,
                                 nil,
                                 @Flags,
                                 nil,
                                 @pSampleLoc));

    if ((Flags and MF_SOURCE_READERF_STREAMTICK) <> 0) then
      Continue;

    // To be on the safe side we check all flags for which
    // further reading would not make any sense
    // and set EndOfFile to True
    if ((Flags and MF_SOURCE_READERF_ENDOFSTREAM) <> 0) or
      ((Flags and MF_SOURCE_READERF_ERROR) <> 0) or
      ((Flags and MF_SOURCE_READERF_NEWSTREAM) <> 0) or
      ((Flags and MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) <> 0) or
      ((Flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <> 0) then
    begin
      fEndOfFile := True;
      Break;
    end;

    if (pSampleLoc <> nil) then
    begin
      SafeRelease(pSample);
      pSample := pSampleLoc;
      hr := pSample.GetSampleTime(Timestamp);

      if SUCCEEDED(hr) then
        hr := pSample.GetSampleDuration(Duration);

      // fVideoInfo.Duration can return the wrong value!
      // if Timestamp + Duration >= fVideoInfo.Duration then
      // fEndOfFile := True;
      if FAILED(hr) then
        begin
          fEndOfFile := True;
          pSample := nil;
        end;
      Break;
      sleep(0);
    end;
    // Can it happen that we get an infinite loop here?
  until False;
end;


procedure TVideoTransformer.NextValidSampleToBitmap(const bm: TBitmap;
                                                    out Timestamp: Int64;
                                                    out Duration: Int64);
var
  Count: Integer;
  pSample: IMFSample;
  pBuffer: IMFMediaBuffer;
  Stride: Integer;
  pRow, pData: PByte;
  ImageSize: DWord;

const
  ProcName = 'TVideoTransformer.NextValidSampleToBitmap';

  procedure CheckFail(hr: HResult);
    begin
      inc(Count);
      if FAILED(hr) then
        begin
          raise Exception.CreateFmt('Fail in call nr. %d of with result $%s',
                                    [Count,
                                    IntToHex(hr, 8)]);

        end;
    end;

begin
  if fEndOfFile then
    Exit;

  Count := 0;
  GetNextValidSample(pSample,
                     Timestamp,
                     Duration);

  // an invalid sample is nil
  if Assigned(pSample) then
    begin
      CheckFail(pSample.ConvertToContiguousBuffer(pBuffer));
      if Assigned(pBuffer) then
        begin
          bm.PixelFormat := pf32bit;
          bm.SetSize(fNewWidth, fNewHeight);
         Stride := 4 * fNewWidth;
         pRow := bm.ScanLine[0];
         CheckFail(pBuffer.Lock(pData,
                                nil,
                                @ImageSize));
         // Assert(ImageSize = 4 * fNewWidth * fNewHeight);
         CheckFail(MFCopyImage(pRow { Destination buffer. },
                               -Stride { Destination stride. },
                               pData,
                               { First row in source. }
                               Stride { Source stride. },
                               Stride { Image width in bytes. },
                               fNewHeight { Image height in pixels. } ));

      CheckFail(pBuffer.Unlock);
      CheckFail(pBuffer.SetCurrentLength(0));
      SafeRelease(pBuffer);
    end;
    sleep(0);
  end;
end;

{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

end.
