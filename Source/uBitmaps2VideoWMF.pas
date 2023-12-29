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

unit uBitmaps2VideoWMF;

interface

// some of the interface stuff fails with optimization turned on
// optimization will be turned on where it matters
{$IFOPT O+ }
{$DEFINE O_PLUS }
{$O- }
{$ENDIF }

uses
  {WinApi}
  WinApi.Windows,
  WinApi.ActiveX,
  WinApi.WinError,
  WinApi.WinApiTypes,
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
  WinApi.MediaFoundationApi.MfMetLib,
  WinApi.MediaFoundationApi.MfReadWrite,
  WinApi.MediaFoundationApi.Mfobjects,
  WinApi.MediaFoundationApi.CodecApi,
  WinApi.ActiveX.PropIdl,
  WinApi.MediaFoundationApi.MfIdl,
  {Application}
  // parallel bitmap resampler
  uScaleWMF,
  uScaleCommonWMF,
  //Transforms video-samples to the input-format of the sinkwriter
  uTransformer,
  uToolsWMF;

type

  TCodecID = (ciH264,
              ciH265);

  TVideoFileExtensions = (vfeMp4, vfeAvi, vfewmv);

  TCodecIDArray = array of TCodecID;

const
  CodecNames: array [TCodecID] of string = ('H264 (Mpeg-4, AVC)',
                                            'H265 (HEVC)');

  CodecShortNames: array [TCodecID] of string = ('H264',
                                                 'H265');

  CodecInfos: array [TCodecID] of string = ('Uses hardware-encoding, if supported.' + #13 +
                                            'If not, falls back to software-encoding.',
                                            'Uses hardware-encoding, if supported.' + #13 +
                                            'If not, falls back to software-encoding.' + #13 +
                                            'Better quality per bitrate than H264.' + #13 +
                                            'Requires Windows 10 or higher');

  VideoContaineFormatExtensions: array [TVideoFileExtensions] of string = ('.mp4',
                                                                           '.avi',
                                                                           '.wmv');



type
  // TZoom is a record (xcenter, ycenter, radius) defining a virtual zoom-rectangle
  // (xcenter-radius, ycenter-radius, xcenter+radius, ycenter+radius).
  // This rectangle should be a sub-rectangle of [0,1]x[0,1].
  // If multipied by the width/height of a target rectangle, it defines
  // an aspect-preserving sub-rectangle of the target.
  TZoom = record
    xCenter: Single;
    yCenter: Single;
    Radius: Single;

    function ToRectF(Width,
                     Height: Integer): TRectF; inline;
  end;

const
  _FullZoom: TZoom = (xCenter: 0.5;
                      yCenter: 0.5;
                      Radius: 0.5);

type
  eAudioFormatException = class(Exception);

  // Can be a method of a class or free standing or anonymous
  TBitmapEncoderProgressEvent = reference to procedure(Sender: TObject;
                                                       FrameCount: Cardinal;
                                                       VideoTime: Int64;
                                                       var DoAbort: Boolean);

type

  TBitmapEncoderWMF = class
  private
    { fields needed to set up the MF-Sinkwriter and Sourcereader }
    fVideoWidth: DWord;
    fVideoHeight: DWord;
    fVideoFrameRate: Double;
    fQuality: DWord;

    fSampleDuration: DWord;
    fInputFormat: TGUID;
    pSinkWriter: IMFSinkWriter;
    pSourceReader: IMFSourceReader;
    pMediaTypeOut: IMFMediaType;
    pMediaTypeIn: IMFMediaType;

    pSampleBuffer: IMFMediaBuffer;
    pSampleBufferAudio: IMFMediaBuffer;
    fBufferSizeVideo: UINT32;
    fBufferSizeAudio: UINT32;
    fstreamIndex: DWord;
    fSinkStreamIndexAudio: DWord;

    hrCoInit: HResult;
    fFileName: string;

    // Audio
    fAudioFileName: string;
    fAudioFormat: TMFAudioFormat;
    //fAudioBitrate: Double;
    //fAudioSampleRate: Double;
    fAudioBitrate: UINT32;
    fAudioSampleRate: UINT32;
    fAudioDuration: Int64;
    fAudioTime: Int64;
    fAudioDone: Boolean;
    pAudioTypeIn: IMFMediaType;
    pAudioTypeOut: IMFMediaType;
    pAudioTypeNative: IMFMediaType;
    fAudioStreamIndex: DWord;
    fAudioBytesPerSecond: UINT32;
    fAudioBlockAlign: UINT32;
    fCodec: TCodecID;
    { /fields needed to set up the MF-Sinkwriter }

    fWriteStart: Int64;
    fReadAhead: Int64;
    fInitialized: Boolean;
    fWriteAudio: Boolean;
    fAudioStart: Int64;
    fBottomUp: Boolean;
    fVideoTime: Int64;
    fFrameCount: Int64;
    fThreadPool: TResamplingThreadPool;
    fFilter: TFilter;
    fTimingDebug: Boolean;
    fBrake: Integer;
    fEffectTime: Int64;

    fBmRGBA: TBitmap;
    fOnProgress: TBitmapEncoderProgressEvent;

    // Resize/crop bm to input format for the encoder.
    procedure BitmapToRGBA(const bmSource,
                           bmRGBA: TBitmap;
                           crop: Boolean);

    // Move the RGBA-pixels into an MF sample buffer
    procedure bmRGBAToSampleBuffer(const bm: TBitmap);

    // Encode one frame to video stream and the corresponding audio samples to audio stream
    function WriteOneFrame(TimeStamp: Int64;
                           Duration: Int64): HResult;

    function WriteAudio(TimeStamp: Int64): HResult;

    function InitAudio(const AudioFileName: string;
                       const StreamIndex: DWord): HResult;

    function GetSilenceBufferSize(Duration: Int64): DWord;

    function GetAudioDuration(PCMSamples: DWord): Int64;

  public

    constructor Create();

    /// <summary> Set up the video encoder for writing one output file. </summary>
    /// <param name="Filename">Name of the output file. Must have extension .mp4. .wmv presently not supported. </param>
    /// <param name="Width">Video width in pixels. </param>
    /// <param name="Height">Video height in pixels. </param>
    /// <param name="Quality">Quality of the video encoding on a scale of 1 to 100</param>
    /// <param name="VideoFrameRate">Frame rate in frames per second. Value >= 30 recommended.</param>
    /// <param name="VideoCodec">Video codec enum for encoding. Presently ciH264 or ciH265</param>
    /// <param name="AudioFormat">The Audio format structure (TMFAudioFormat)
    /// <param name="Resampler">Enum defining the quality of resizing. cfBox, cfBilinear, cfBicubic or cfLanczos </param>
    /// <param name="AudioFileName">Optional audio or video file (.wav, .mp3, .aac, .mp4 etc.). The audio stream encoder see AudioCodec param. </param>
    /// <param name="AudioStart"> Delay of audio start in ms. Default 0 </param>
    function Initialize(const Filename: string;
                        Width: Integer;
                        Height: Integer;
                        Quality: UInt32;
                        VideoFrameRate: Double;
                        VideoCodec: TCodecID;
                        AudioFormat: TMFAudioFormat;
                        Resampler: TFilter = cfBicubic;
                        const AudioFileName: string = '';
                        AudioStart: Int64 = 0): HResult;

    /// <summary> Finishes input, frees resources and closes the output file. </summary>
    procedure Finalize();

    /// <summary> Encodes a bitmap as the next video frame. Will be resized to maximal size fitting the video size (black BG), or (crop=True) cropped for maximal borderless size. </summary>
    procedure AddFrame(const bm: TBitmap;
                       crop: Boolean);

    /// <summary> Repeatedly encode the last frame for EffectTime ms </summary>
    procedure Freeze(EffectTime: Int64);

    /// <summary> Show a bitmap for ShowTime ms</summary>
    /// If option spread the showtime per frame over the length of the audio duration.
    /// ShowTime = (duration div bitmaps) - Effecttime.
    procedure AddStillImage(const bm: TBitmap;
                            ShowTime: Integer;
                            UseAudioDuration: Boolean;
                            crop: Boolean);

    /// <summary> Make a crossfade transition from Sourcebm to Targetbm lasting EffectTime ms </summary>
    procedure CrossFade(const Sourcebm: TBitmap;
                        const Targetbm: TBitmap;
                        EffectTime: Integer;
                        cropSource: Boolean;
                        cropTarget: Boolean);

    /// <summary> Make a crossfade transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure CrossFadeTo(const Targetbm: TBitmap;
                          EffectTime: Integer;
                          cropTarget: Boolean);

    /// <summary> Another transition as an example of how you can make more. Transition from Sourcebm to Targetbm </summary>
    procedure ZoomInOutTransition(const Sourcebm: TBitmap;
                                  const Targetbm: TBitmap;
                                  ZoomSource: TZoom;
                                  ZoomTarget: TZoom;
                                  EffectTime: Integer;
                                  cropSource: Boolean;
                                  cropTarget: Boolean);

    /// <summary> Zoom-in-out transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure ZoomInOutTransitionTo(const Targetbm: TBitmap;
                                    ZoomSource: TZoom;
                                    ZoomTarget: TZoom;
                                    EffectTime: Integer;
                                    cropTarget: Boolean);

    /// <summary> Insert a video clip (video stream only) into the stream of encoded bitmaps. </summary>
    /// <param name="VideoFile">Name of the file containing the video clip. Anything that Windows can decode should be supported. </param>
    /// <param name="TransitionTime">Optionally does a crossfade transition from the last encoded frame to the first video frame lasting TransitionTime ms. Default 0 </param>
    /// <param name="Crop">Optionally crops video frames. </summary>
    procedure AddVideo(const VideoFile: string;
                       TransitionTime: Integer = 0;
                       crop: Boolean = False);

    destructor Destroy(); override;

    // Videotime in ms.
    property VideoTime: Int64 read fVideoTime;

    // Count of frames added.
    property FrameCount: Int64 read fFrameCount;

    // The filename of the output video as entered in Initialize.
    property Filename: string read fFileName;

    // The last encoded frame returned as a TBitmap.
    property LastFrame: TBitmap read fbmRGBA;

    // If True, timestamp in sec will be displayed on the frames. A rough check for a uniform timing of frames.
    // Timing could be very irregular at the beginning of development with high frame rates and large video sizes.
    // I had to artificially slow down the generation of some frames to (hopefully) fix it,
    // and read ahead in the audio file.
    // See Freeze and WriteAudio.
    property TimingDebug: Boolean read fTimingDebug write fTimingDebug;

    property EffectTime: Int64 read fEffectTime;
    property AudioDuration: Int64 read fAudioDuration;

    // Event which fires every 30 frames. Use to indicate progress or abort encoding.
    property OnProgress: TBitmapEncoderProgressEvent read fOnProgress write fOnProgress;
  end;

  function GetSupportedCodecs(const FileExt: string): TCodecIDArray;

  /// <summary>Use TBitmapEncoderWMF to re-encode a video to H265 or H264 and AAC,
  /// changing video size and/or frame rate.
  /// Audio of the 1st audio-stream is used.</summary>
  procedure TranscodeVideoFile(const InputFilename: string;
                               const OutputFilename: string;
                               VideoCodec: TCodecID;
                               AudioFormat: TMFAudioFormat;
                               Quality: Integer;
                               NewWidth: Integer;
                               NewHeight: Integer;
                               NewFrameRate: Single;
                               crop: Boolean = False;
                               OnProgress: TBitmapEncoderProgressEvent = nil);

implementation


procedure TranscodeVideoFile(const InputFilename: string;
                             const OutputFilename: string;
                             VideoCodec: TCodecID;
                             AudioFormat: TMFAudioFormat;
                             Quality: Integer;
                             NewWidth: Integer;
                             NewHeight: Integer;
                             NewFrameRate: Single;
                             crop: Boolean = False;
                             OnProgress: TBitmapEncoderProgressEvent = nil);
var
  bme: TBitmapEncoderWMF;

begin
  bme := TBitmapEncoderWMF.Create();
  try
    // use the 1st audio-stream of the input file as audio
    bme.Initialize(OutputFilename,
                   NewWidth,
                   NewHeight,
                   Quality,
                   NewFrameRate,
                   VideoCodec,
                   AudioFormat,
                   cfBilinear,
                   InputFilename,
                   0);

    bme.OnProgress := OnProgress;

    bme.AddVideo(InputFilename,
                 0,
                 crop);
  finally
    bme.Free;
  end;
end;


const
  // .wmv requires bottom-up order of input to the sample buffer
  // ... or is it the other way round? Anyway, the code works.
  BottomUp: array [TCodecID] of Boolean = (False,
                                           False);

// List of codecs supported for encoding a file with the given extension
function GetSupportedCodecs(const FileExt: string): TCodecIDArray;
begin
  SetLength(Result,
            0);

  if (FileExt = '.mp4') or (FileExt = '.avi')then
    begin
      SetLength(Result,
                2);

      Result[0] := ciH264;
      Result[1] := ciH265;
    end;

  // We currently don't support .wmv, too many problems.
  // if FileExt = '.wmv' then
  // begin
  // SetLength(result, 1);
  // result[0] := ciWMV;
  // end;
end;


// translation of our codec-enumeration to MF-constants
function GetEncodingFormat(Id: TCodecID): TGUID;
begin
  case Id of
    ciH264: Result := MFVideoFormat_H264;
    ciH265: Result := MFVideoFormat_HEVC;
    // ciWMV:
    // result := MFVideoFormat_WMV3;
  end;
end;

// record to divide up the work of a loop into threads.
type
  TParallelizer = record
    // array of loopbounds for each thread
    imin: TIntArray;
    imax: TIntArray;
    // InputCount: length of the loop
    procedure Init(ThreadCount: Integer;
                   InputCount: Integer);
  end;


procedure TParallelizer.Init(ThreadCount: Integer;
                             InputCount: Integer);
var
  chunk,
  Index: Integer;

begin
  SetLength(imin,
            ThreadCount);
  SetLength(imax,
            ThreadCount);

  chunk := InputCount div ThreadCount;

  for Index := 0 to ThreadCount - 1 do
    begin
      imin[Index] := Index * chunk;
      if (Index < ThreadCount - 1) then
        imax[Index] := (Index + 1) * chunk - 1
      else
        imax[Index] := InputCount - 1;
    end;
end;


function IsCodecSupported(const FileExt: string;
                          Codec: TCodecID): Boolean;
var
  ca: TCodecIDArray;
  i: Integer;

begin
  Result := False;
  ca := GetSupportedCodecs(FileExt);
  for i := 0 to Length(ca) - 1 do
    if (ca[i] = Codec) then
      begin
        Result := True;
        Break;
      end;
end;


{ TBitmapEncoderWMF }

type
  TGUIDArray = array of TGUID;


function IntermediateVideoFormats: TGUIDArray;
begin
  SetLength(Result,
            4);
  result[0] := MFVideoFormat_NV12;
  result[1] := MFVideoFormat_YV12;
  result[2] := MFVideoFormat_YUY2;
  result[3] := MFVideoFormat_RGB32;
end;


function IntermediateAudioFormats: TGUIDArray;
begin
  SetLength(Result,
            2);
  Result[1] := MFAudioFormat_Float;
  Result[0] := MFAudioFormat_PCM;
end;


const
  nIntermediateVideoFormats = 4;
  nIntermediateAudioFormats = 2;


function TBitmapEncoderWMF.GetSilenceBufferSize(Duration: Int64): DWord;
var
  dwRes: DWord;
begin
  dwRes := Round(fAudioBytesPerSecond / 1000 * Duration / 10000);
  Result := fAudioBlockAlign * (dwRes div fAudioBlockAlign);
end;


function TBitmapEncoderWMF.GetAudioDuration(PCMSamples: DWord): Int64;
begin
  Result := Round(PCMSamples / fAudioSampleRate * 1000 * 10000);
end;


function TBitmapEncoderWMF.Initialize(const Filename: string;
                                      Width: Integer;
                                      Height: Integer;
                                      Quality: UInt32;
                                      VideoFrameRate: Double;
                                      VideoCodec: TCodecID;
                                      AudioFormat: TMFAudioFormat;
                                      Resampler: TFilter = cfBicubic;
                                      const AudioFileName: string = '';
                                      AudioStart: Int64 = 0): HResult;
const
  ProcName = 'TBitmapEncoderWMF.Initialize';

var
  hr: HResult;
  attribs: IMFAttributes;
  stride: DWord;
  ext: string;
  AudioBitrate: Integer;
  AudioSampleRate: Integer;

label
  done;

begin

  if fInitialized then
    begin
      raise Exception.Create('The bitmap-encoder must be finalized before re-initializing');
    end;

  fInitialized := False;
  fFileName := Filename;
  ext := ExtractFileExt(fFileName);

  if not IsCodecSupported(ext,
                          VideoCodec) then
    begin
      raise Exception.CreateFmt('%s %s %s %s',
                                ['Codec',
                                 CodecShortNames[VideoCodec],
                                 'not supported for file type',
                                 ext]);
    end;

  fVideoWidth := Width;
  fVideoHeight := Height;
  fBrake := Max(Round(4800 / fVideoHeight),
                1);
  fQuality := Quality;
  fVideoFrameRate := VideoFrameRate;
  fFilter := Resampler;
  fCodec := VideoCodec;
  fAudioFileName := AudioFileName;

  // Calculate the average time/frame
  // Time is measured in units of 100 nanoseconds. 1 sec = 1000 * 10000 time-units
  fSampleDuration := Round(1000 * 10000 / fVideoFrameRate);
  fAudioStart := AudioStart * 10000;
  fInputFormat := MFVideoFormat_RGB32;
  fBottomUp := BottomUp[VideoCodec];

  fWriteStart := 0;
  fFrameCount := 0;
  fstreamIndex := 0;

  stride := 4 * fVideoWidth;

  hrCoInit := CoInitializeEx(nil,
                             COINIT_APARTMENTTHREADED);
  hr := hrCoInit;
  if FAILED(hr) then
    goto done;

  hr := MFStartup(MF_VERSION);
  if FAILED(hr) then
    goto done;

  hr := MFCreateAttributes(attribs,
                           3);
  if FAILED(hr) then
    goto done;

  // this enables hardware encoding, if the GPU supports it
  hr := attribs.SetUInt32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS,
                          UInt32(True));
  if FAILED(hr) then
    goto done;

  // Here we set the container type on the sinkwriter.
  if ExtractFileExt(Filename) = VideoContaineFormatExtensions[vfeMp4] then
    hr := attribs.SetGUID(MF_TRANSCODE_CONTAINERTYPE,
                          MFTranscodeContainerType_MPEG4)
  else if ExtractFileExt(Filename) = VideoContaineFormatExtensions[vfeAvi] then
    hr := attribs.SetGUID(MF_TRANSCODE_CONTAINERTYPE,
                          MFTranscodeContainerType_AVI)
  else if ExtractFileExt(Filename) = VideoContaineFormatExtensions[vfewmv] then
    hr := attribs.SetGUID(MF_TRANSCODE_CONTAINERTYPE,
                          MFTranscodeContainerType_ASF)
  else
    hr := ERROR_INVALID_PARAMETER;

  if FAILED(hr) then
    goto done;


  // Remarks:
  // Low latency is defined as the smallest possible delay from when the media data is
  // generated (or received) to when it is rendered.
  // Low latency is desirable for real-time communication scenarios.
  // For other scenarios, such as local playback or transcoding,
  // you typically should not enable low-latency mode, because it can affect quality.
  // hr := attribs.SetUInt32(MF_LOW_LATENCY,
  //                         UInt32(True));
  // if FAILED(hr) then
  //   goto done;
  //
  // Setting this to True makes the timings more uneven
  // Remarks:
  // By default, the sink writer's IMFSinkWriter.WriteSample method limits the data rate by
  // blocking the calling thread.
  // This prevents the application from delivering samples too quickly.
  // To disable this behavior, set the MF_SINK_WRITER_DISABLE_THROTTLING attribute
  // to TRUE when you create the sink writer.
   hr := attribs.SetUInt32(MF_SINK_WRITER_DISABLE_THROTTLING,
                           UInt32(True));
   if FAILED(hr) then
     goto done;

  // This seems to improve the quality of encodings:
  // This enables the encoder to use quality based settings.
  // NOTE: Do not use. These are DirectShow features!
  //hr := attribs.SetUInt32(CODECAPI_AVEncCommonRateControlMode,
  //                        3);
  //if FAILED(hr) then
  //  goto done;

  //hr := attribs.SetUInt32(CODECAPI_AVEncCommonQuality,
  //                        fQuality);
  //if FAILED(hr) then
  //  goto done;

  // Sacrifice speed for details
  //hr := attribs.SetUInt32(CODECAPI_AVEncCommonQualityVsSpeed,
  //                        Quality);
  //if FAILED(hr) then
  //  goto done;

  //
  // Create a sinkwriter to write the output file.
  //
  hr := MFCreateSinkWriterFromURL(PWideChar(Filename),
                                  nil,
                                  attribs,
                                  pSinkWriter);
  if FAILED(hr) then
    goto done;


  // Set the output media type.
  hr := MFCreateMediaType(pMediaTypeOut);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeOut.SetGUID(MF_MT_MAJOR_TYPE,
                              MFMediaType_Video);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeOut.SetGUID(MF_MT_SUBTYPE,
                              GetEncodingFormat(VideoCodec));
  if FAILED(hr) then
    goto done;

  // Has no effect on the bitrate with quality based encoding, it could have an effect
  // on the size of the leaky bucket buffer. So we leave it here.
  hr := pMediaTypeOut.SetUInt32(MF_MT_AVG_BITRATE,
                                fQuality * 60 * fVideoHeight);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeOut.SetUInt32(MF_MT_INTERLACE_MODE,
                                MFVideoInterlace_Progressive);
  if FAILED(hr) then
    goto done;

  hr := MFSetAttributeSize(pMediaTypeOut,
                           MF_MT_FRAME_SIZE,
                           fVideoWidth,
                           fVideoHeight);
  if FAILED(hr) then
    goto done;

  hr := MFSetAttributeRatio(pMediaTypeOut,
                            MF_MT_FRAME_RATE,
                            Round(fVideoFrameRate * 100),
                            100);
  if FAILED(hr) then
    goto done;

  // It doesn't seem to do the following
  // hr := pMediaTypeOut.SetUInt32(CODECAPI_AVEncMPVGOPSize,
  //                               Round(0.5 * fFrameRate)));

  hr := MFSetAttributeRatio(pMediaTypeOut,
                            MF_MT_PIXEL_ASPECT_RATIO,
                            1,
                            1);
  if FAILED(hr) then
    goto done;

  // Add a stream with the ouput media type to the sink-writer.
  // fstreamIndex (always 0) is our video-stream-index.
  hr := pSinkWriter.AddStream(pMediaTypeOut,
                              fstreamIndex);
  if FAILED(hr) then
    goto done;

  // Set the input media type.
  hr := MFCreateMediaType(pMediaTypeIn);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeIn.SetGUID(MF_MT_MAJOR_TYPE,
                             MFMediaType_Video);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeIn.SetGUID(MF_MT_SUBTYPE,
                             MFVideoFormat_RGB32);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeIn.SetUInt32(MF_MT_INTERLACE_MODE,
                               MFVideoInterlace_Progressive);
  if FAILED(hr) then
    goto done;

  hr := MFSetAttributeSize(pMediaTypeIn,
                           MF_MT_FRAME_SIZE,
                           fVideoWidth,
                           fVideoHeight);
  if FAILED(hr) then
    goto done;

  hr := MFSetAttributeRatio(pMediaTypeIn,
                            MF_MT_FRAME_RATE,
                            Round(fVideoFrameRate * 100),
                            100);
  if FAILED(hr) then
    goto done;

  hr := MFSetAttributeRatio(pMediaTypeIn,
                            MF_MT_PIXEL_ASPECT_RATIO,
                            1,
                            1);
  if FAILED(hr) then
    goto done;

  hr := pMediaTypeIn.SetUInt32(MF_MT_ALL_SAMPLES_INDEPENDENT,
                               UInt32(True));
  if FAILED(hr) then
    goto done;

  hr := pSinkWriter.SetInputMediaType(fstreamIndex,
                                      pMediaTypeIn,
                                      nil);
  if FAILED(hr) then
    goto done;

  //
  // Audio init
  //
  if FileExists(AudioFileName) then
    begin

      // copy given audio format struct.
      CopyMemory(@fAudioFormat,
                 @AudioFormat,
                 SizeOf(TMFAudioFormat));


      hr := InitAudio(AudioFileName,
                      MF_SOURCE_READER_FIRST_AUDIO_STREAM);
      if FAILED(hr) then
        goto done;

      // prevent memory leak if the the audiofile contains more than
      // 1 stream
      pSourceReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS,
                                       False);

      // Ensure the stream is selected.
      hr := pSourceReader.SetStreamSelection(fAudioStreamIndex,
                                             True);
      if FAILED(hr) then
        goto done;
  end;

  fBmRGBA.PixelFormat := pf32bit;
  fBmRGBA.SetSize(fVideoWidth,
                  fVideoHeight);

  // Tell the sink writer to start accepting data.
  hr := pSinkWriter.BeginWriting();
  if FAILED(hr) then
    goto done;

  fBufferSizeVideo := stride * fVideoHeight;

  hr := MFCreateMemoryBuffer(fBufferSizeVideo,
                             pSampleBuffer);
  if FAILED(hr) then
    goto done;

  fInitialized := True;

done:
  if FAILED(hr) then
    begin
      raise Exception.CreateFmt('%s Procedure: %s Result: %s',
                                [SysErrorMessage(hr) + #13,
                                 ProcName + #13,
                                 IntToHex(hr, 8)]);
    end;
  Result := hr;

end;



// StreamIndex is for future use, presently always set to the 1st audio stream.
function TBitmapEncoderWMF.InitAudio(const AudioFileName: string;
                                     const StreamIndex: DWord): HResult;
const
  ProcName = 'TBitmapEncoderWMF.Initialize';

var
  hr: HResult;
  sysErrmsg: string;
  pData: PByte;
  pPartialType: IMFMediaType;

label
  done;

begin

  fAudioSampleRate := fAudioFormat.unSamplesPerSec;
  fAudioBitrate := fAudioFormat.unAvgBytesPerSec;

  fWriteAudio := True;
  fAudioDone := False;
  fAudioStreamIndex := StreamIndex;

  // Create the encoded media type (AAC stereo with the specified sample- and bit-rates)
  // We set it up independent of the input type. In a future version we want to
  // add more than one audio file, so the input type should be allowed to change,
  // but not the output type.
  // So far it seems to work OK with one audio file.
  hr := MFCreateMediaType(pAudioTypeOut);
  if FAILED(hr) then
    goto done;

  hr := pAudioTypeOut.SetGUID(MF_MT_MAJOR_TYPE,
                              MFMediaType_Audio);
  if FAILED(hr) then
    goto done;

  //  AAC, Dolby or MP3
  hr := pAudioTypeOut.SetGUID(MF_MT_SUBTYPE,
                              fAudioFormat.tgSubFormat);
  if FAILED(hr) then
    goto done;

  // Set the number of audio bits per sample. This must be 16 according to docs.
  hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_BITS_PER_SAMPLE,
                                16);
  if FAILED(hr) then
    goto done;

  // set the number of audio samples per second. Must be 44100 or 48000
  hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_SAMPLES_PER_SECOND,
                                fAudioFormat.unSamplesPerSec);
  if FAILED(hr) then
    goto done;

  // Set the number of audio channels. Hardwired to stereo, can be different from input format.
  hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_NUM_CHANNELS,
                                fAudioFormat.unChannels);
  if FAILED(hr) then
    goto done;

  if (fAudioFormat.unChannels > 2) then
    begin
      hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_CHANNEL_MASK,
                                    fAudioFormat.unChannelMask);
      if FAILED(hr) then
        goto done;
    end;


  // Set the bps of the audio stream
  hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
                                fAudioFormat.unAvgBytesPerSec); // Trunc(125 * fAudioBitrate)
  if FAILED(hr) then
    goto done;

  // Set the block alignment of the samples.
  // Note: For PCM audio formats,
  //       the block alignment is equal to the number of audio channels multiplied by
  //       the number of bytes per audio sample.
  hr := pAudioTypeOut.SetUInt32(MF_MT_AUDIO_BLOCK_ALIGNMENT,
                                fAudioFormat.unBlockAlignment);
  if FAILED(hr) then
    goto done;

  // When AAC is the selected format, we need to set the profilelevel and optionally the payload.
  if IsEqualGuid(fAudioFormat.tgSubFormat,
                 MFAudioFormat_AAC) then
    begin
      hr := pAudioTypeOut.SetUInt32(MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION,
                                    fAudioFormat.unAACProfileLevel);  // AAC Level 2 profile UInt32($29)

      if SUCCEEDED(hr) then
        hr := pAudioTypeOut.SetUInt32(MF_MT_AAC_PAYLOAD_TYPE,
                                      fAudioFormat.unAACPayload);  // Starting in Windows 8, the value can be 0 (raw AAC) or 1 (ADTS AAC).
                                                                   // Other values (2 and 3) are not supported!
     if FAILED(hr) then
       goto done;
    end;

  // add a stream with this media type to the sink-writer
  hr := pSinkWriter.AddStream(pAudioTypeOut,
                              fSinkStreamIndexAudio);
  if FAILED(hr) then
    goto done;

  // Create a source-reader to read the audio file
  hr := MFCreateSourceReaderFromURL(PWideChar(AudioFileName),
                                    nil,
                                    pSourceReader);
  if FAILED(hr) then
    goto done;

  // Find the first audio-stream and read its native media type
  // Just to have a reference to it, not used at the moment
  hr := pSourceReader.GetNativeMediaType(fAudioStreamIndex,
                                         0,
                                         pAudioTypeNative);
  if FAILED(hr) then
    begin
      fAudioStreamIndex := MF_SOURCE_READER_FIRST_AUDIO_STREAM;
      hr := pSourceReader.GetNativeMediaType(fAudioStreamIndex,
                                             0,
                                             pAudioTypeNative);
      if FAILED(hr) then
        goto done;

    end;



  // Create a partial uncompressed media type with the specs the reader should decode to.
  hr := MFCreateMediaType(pPartialType);
  if FAILED(hr) then
    goto done;

  // set the major type of the partial type
  hr := pPartialType.SetGUID(MF_MT_MAJOR_TYPE,
                             MFMediaType_Audio);
  if FAILED(hr) then
    goto done;

  // MFAudioFormat_PCM is required as input for AAC
  hr := pPartialType.SetGUID(MF_MT_SUBTYPE,
                             MFAudioFormat_PCM);
  if FAILED(hr) then
    goto done;

  hr := pPartialType.SetUInt32(MF_MT_AUDIO_BITS_PER_SAMPLE,
                               16);
  if FAILED(hr) then
    goto done;

  hr := pPartialType.SetUInt32(MF_MT_AUDIO_SAMPLES_PER_SECOND,
                               fAudioSampleRate);
  if FAILED(hr) then
    goto done;

  hr := pPartialType.SetUInt32(MF_MT_AUDIO_NUM_CHANNELS,
                               2);
  if FAILED(hr) then
    goto done;

  hr := pPartialType.SetUInt32(MF_MT_ALL_SAMPLES_INDEPENDENT,
                               UInt32(True));
  if FAILED(hr) then
    goto done;

  // set the partial media type on the source stream
  // if this is successful, the reader can deliver uncompressed samples
  // in the given format
  hr := pSourceReader.SetCurrentMediaType(fAudioStreamIndex,
                                          0,
                                          pPartialType);
  if FAILED(hr) then
    goto done;

  // Read the full uncompressed input type off the reader
  hr := pSourceReader.GetCurrentMediaType(fAudioStreamIndex,
                                          pAudioTypeIn);
  if FAILED(hr) then
    goto done;

  // Set this type as input type for the sink-writer. If this is successful
  // we are ready to encode.
  hr := pSinkWriter.SetInputMediaType(fSinkStreamIndexAudio, // stream index
                                      pAudioTypeIn, // media type to match
                                      nil); // configuration attributes for the encoder
  if FAILED(hr) then
    goto done;

  // Find the audio-duration
  hr := GetFileDuration(pSourceReader,
                        fAudioDuration);
  if FAILED(hr) then
    goto done;

  fAudioTime := 0;

  // Set up an audio buffer holding silence which we can add to the audio stream as necessary
  hr := pAudioTypeIn.GetUInt32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
                               fAudioBytesPerSecond);
  if FAILED(hr) then
    goto done;

  hr := pAudioTypeIn.GetUInt32(MF_MT_AUDIO_BLOCK_ALIGNMENT,
                               fAudioBlockAlign);
  if FAILED(hr) then
    goto done;

  // Create an audio-buffer that holds silence
  // the buffer should hold audio for the  video frame time.
  fBufferSizeAudio := GetSilenceBufferSize(fSampleDuration);

  hr := MFCreateMemoryBuffer(fBufferSizeAudio,
                             pSampleBufferAudio);
  if FAILED(hr) then
    goto done;

  hr := pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio);
  if FAILED(hr) then
    goto done;

  hr := pSampleBufferAudio.Lock(pData,
                                nil,
                                nil);
  if FAILED(hr) then
    goto done;

  FillChar(pData^,
           fBufferSizeAudio,
           0);

  // prevent crack at beginnning of silence
  PByteArray(pData)[2] := $06;

  hr := pSampleBufferAudio.Unlock();
  if FAILED(hr) then
    goto done;

  hr := pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio);
  if FAILED(hr) then
    goto done;

  // Set the amount of time we read ahead of the video-timestamp in the audio-file
  fReadAhead := 4 * GetAudioDuration(1024); // duration of 4 encoded AAC-frames

done:
  if FAILED(hr) then
    begin
      sysErrmsg := SysErrorMessage(hr);
      raise Exception.CreateFmt('%s Procedure: %s Result: %s',
                                [sysErrmsg + #13,
                                 ProcName + #13,
                                 IntToHex(hr, 8)]);
    end;
  Result := hr;
end;


procedure TBitmapEncoderWMF.Finalize();
begin

  if Assigned(pSinkWriter) then
    pSinkWriter.Finalize();

  pSinkWriter := nil;

  if Assigned(pSourceReader) then
    SafeRelease(pSourceReader);

  pSourceReader := nil;

  MFShutdown();

  if SUCCEEDED(hrCoInit) then
    CoUninitialize();
  fInitialized := False;
end;


procedure TBitmapEncoderWMF.AddVideo(const VideoFile: string;
                                     TransitionTime: Integer = 0;
                                     crop: Boolean = False);
var
  VT: TVideoTransformer;
  bm: TBitmap;
  TimeStamp, Duration, VideoStart: Int64;

begin
  VT := TVideoTransformer.Create(VideoFile,
                                 fVideoHeight,
                                 fVideoFrameRate);
  try
    bm := TBitmap.Create();
    try
      VT.NextValidSampleToBitmap(bm,
                                 TimeStamp,
                                 Duration);

      if (TransitionTime > 0) then
        CrossFadeTo(bm,
                    TransitionTime,
                    crop);

      VideoStart := fWriteStart;

      // fill gap at beginning of video stream

      if (TimeStamp > 0) then
        AddStillImage(bm,
                      Round(TimeStamp / 10000),
                      False,
                      crop);

      while (not VT.EndOfFile) and fInitialized do
        begin
          BitmapToRGBA(bm,
                       fBmRGBA,
                       crop);

          bmRGBAToSampleBuffer(fBmRGBA);
          WriteOneFrame(VideoStart + TimeStamp,
                        Duration);

//        if fFrameCount mod 10 = 1 then
//          sleep(1);  HandleThreadMessages(GetCurrentThread);

          VT.NextValidSampleToBitmap(bm,
                                     TimeStamp,
                                     Duration);
      end;
    finally
      bm.Free;
    end;
  finally
    VT.Free;
  end;
end;


procedure TBitmapEncoderWMF.AddFrame(const bm: TBitmap;
                                     crop: Boolean);
begin
  BitmapToRGBA(bm,
               fBmRGBA,
               crop);

  bmRGBAToSampleBuffer(fBmRGBA);
  WriteOneFrame(fWriteStart,
                fSampleDuration);
end;


procedure TBitmapEncoderWMF.AddStillImage(const bm: TBitmap;
                                          ShowTime: Integer;
                                          UseAudioDuration: Boolean;
                                          crop: Boolean);
var
  bmBuf: TBitmap;
  StartTime: Int64;
  fLength: Int64;

begin
  StartTime := fWriteStart;
  BitmapToRGBA(bm,
               fBmRGBA,
               crop);

  if fTimingDebug then
    begin
      bmBuf := TBitmap.Create();

      try

        // ShowTime = (duration div bitmaps) - Effecttime.
        if UseAudioDuration then
          fLength := ShowTime
        else
          fLength := StartTime + ShowTime * 10000;


        while (fWriteStart < fLength) do
          begin
            bmBuf.Assign(fBmRGBA);
            bmRGBAToSampleBuffer(bmBuf);
            WriteOneFrame(fWriteStart,
                          fSampleDuration);
          end;
      finally
        bmBuf.Free();
      end;

    end
  else
    begin
      bmRGBAToSampleBuffer(fBmRGBA);
      Freeze(ShowTime);
    end;
end;


// Resizes/crops bmSource to video size.
// We use a bitmap for the RGBA-output rather than a buffer, because we want to do
// bitmap operations like zooming on it.
procedure TBitmapEncoderWMF.BitmapToRGBA(const bmSource: TBitmap;
                                         const bmRGBA: TBitmap;
                                         crop: Boolean);
var
  bmBack, bm: TBitmap;
  w, h, wSource, hSource: DWord;
  SourceRect: TRectF;
  bmWidth, bmHeight: DWord;

begin
  if (bmSource.Width = 0) or (bmSource.Height = 0) then
    raise Exception.Create('Bitmap has size 0');

  bmWidth := bmSource.Width;
  bmHeight := bmSource.Height;
  bm := TBitmap.Create();

  try
    bm.Assign(bmSource);
    bm.PixelFormat := pf32bit;

    if (bmWidth <> fVideoWidth) or (bmHeight <> fVideoHeight) then
      begin
        if (bmWidth / bmHeight) > (fVideoWidth / fVideoHeight) then
          begin
            if crop then
              begin
                h := fVideoHeight;
                w := fVideoWidth;
                hSource := bmHeight;
                wSource := Round(hSource * fVideoWidth / fVideoHeight);
                SourceRect := RectF((bmWidth - wSource) div 2,
                                    0,
                                    (bmWidth + wSource) div 2,
                                    bm.Height);
              end
            else
              begin
                w := fVideoWidth;
                h := Round(fVideoWidth * bmHeight / bmWidth);
                SourceRect := RectF(0,
                                    0,
                                    bmWidth,
                                    bmHeight);
             end;
          end
        else
          begin
            if crop then
              begin
                w := fVideoWidth;
                h := fVideoHeight;
                wSource := bm.Width;
                hSource := Round(wSource * fVideoHeight / fVideoWidth);
                SourceRect := RectF(0,
                                    (bmHeight - hSource) div 2,
                                    bmWidth,
                                    (bmHeight + hSource) div 2);
              end
            else
              begin
                h := fVideoHeight;
                w := Round(fVideoHeight * bmWidth / bmHeight);
                SourceRect := FloatRect(0,
                                        0,
                                        bmWidth,
                                        bmHeight);
              end;
      end;

    bmBack := TBitmap.Create();

    try
      uScaleWMF.ZoomResampleParallelThreads(w,
                                            h,
                                            bm,
                                            bmBack,
                                            SourceRect,
                                            fFilter,
                                            0,
                                            amIgnore,
                                            @fThreadPool);

      if (w <> fVideoWidth) or (h <> fVideoHeight) then
        begin
          bmRGBA.PixelFormat := pf32bit;
          bmRGBA.SetSize(fVideoWidth,
                         fVideoHeight);

          bmRGBA.Canvas.Lock;

          BitBlt(bmRGBA.Canvas.Handle,
                 0,
                 0,
                 fVideoWidth,
                 fVideoHeight,
                 0,
                 0,
                 0,
                 BLACKNESS);

          BitBlt(bmRGBA.Canvas.Handle,
                 (fVideoWidth - w) div 2,
                 (fVideoHeight - h) div 2,
                 w,
                 h,
                 bmBack.Canvas.Handle,
                 0,
                 0,
                 SRCCopy);

          bmRGBA.Canvas.Unlock;
        end
      else
        bmRGBA.Assign(bmBack);

      finally
        bmBack.Free;
      end;
    end
  else
    bmRGBA.Assign(bm);

  finally
    bm.Free;
  end;
end;


procedure TBitmapEncoderWMF.bmRGBAToSampleBuffer(const bm: TBitmap);
var
  hr: HResult;
  pRow: PByte;
  StrideSource, StrideTarget: Integer;
  pData: PByte;
  time: string;

begin
  if fTimingDebug then
    begin
      time := IntToStr(fWriteStart div 10000000);
      bm.Canvas.Lock;
      bm.Canvas.Brush.Style := bsClear;
      bm.Canvas.Font.Color := clFuchsia;
      bm.Canvas.Font.Size := 32;
      bm.Canvas.TextOut(10,
                        10,
                        time);
      bm.Canvas.Unlock;
    end;

  if not fBottomUp then
    begin
      StrideSource := 4 * fVideoWidth;
      pRow := bm.ScanLine[fVideoHeight - 1];
    end
  else
    begin
      StrideSource := -4 * Integer(fVideoWidth);
      pRow := bm.ScanLine[0];
    end;

  StrideTarget := 4 * fVideoWidth;
  hr := pSampleBuffer.Lock(pData,
                           nil,
                           nil);

  if SUCCEEDED(hr) then
    begin
      hr := MFCopyImage(pData, { Destination buffer. }
                        StrideTarget, { Destination stride. }
                        pRow, { First row in source image. }
                        StrideSource, { Source stride. }
                        StrideTarget, { Image width in bytes. }
                        fVideoHeight { Image height  in pixels. } );

      if Assigned(pSampleBuffer) then
        pSampleBuffer.Unlock();

      if SUCCEEDED(hr) then
        // Set the data length of the buffer.
        hr := pSampleBuffer.SetCurrentLength(fBufferSizeVideo);
   end;

  if not SUCCEEDED(hr) then
    raise Exception.Create('TBitmapEncoderWMF.bmRGBAToSampleBuffer failed');
end;


constructor TBitmapEncoderWMF.Create();
begin
  // leave enough processors for the encoding threads
  fThreadPool.Initialize(Min(16,
                             TThread.ProcessorCount div 2),
                             tpNormal);
  fBmRGBA := TBitmap.Create();

end;


{$IFOPT O- }
{$DEFINE O_MINUS }
{$O+ }
{$ENDIF }
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$Q-}
{$ENDIF}

function GetCrossFadeProc({const} CF: TParallelizer;
                          Index: Integer;
                          alpha: Byte;
                          pOldStart: PByte;
                          pNewStart: PByte;
                          pTweenStart: PByte): TProc;
begin
  result := procedure
    var
      pold, pnew, pf: PByte;
      i, i1, i2: Integer;
    begin
      i1 := CF.imin[Index];
      i2 := CF.imax[Index];
      pold := pOldStart;
      pnew := pNewStart;
      pf := pTweenStart;
      inc(pold, i1);
      inc(pnew, i1);
      inc(pf, i1);
      for i := i1 to i2 do
      begin
        pf^ := (alpha * (pnew^ - pold^)) div 256 + pold^;
        inc(pf);
        inc(pnew);
        inc(pold);
      end;
    end;
end;
{$IFDEF O_MINUS}
{$O-}
{$UNDEF O_MINUS}
{$ENDIF}
{$IFDEF Q_PLUS}
{$Q+}
{$UNDEF Q_PLUS}
{$ENDIF}


function StartSlowEndSlow(t: Double): Double; inline;
begin
  if t < 0.5 then
    Result := 2 * sqr(t)
  else
    Result := 1 - 2 * sqr(1 - t);
end;


function StartFastEndSlow(t: Double): Double; inline;
begin
  result := 1 - sqr(1 - t);
end;


procedure TBitmapEncoderWMF.CrossFade(const Sourcebm: TBitmap;
                                      const Targetbm: TBitmap;
                                      EffectTime: Integer;
                                      cropSource: Boolean;
                                      cropTarget: Boolean);
var
  DurMs: Integer;

begin
  AddFrame(Sourcebm,
           cropSource);

  DurMs := Round(1 / 10000 * fSampleDuration);

  CrossFadeTo(Targetbm,
              EffectTime - DurMs,
              cropTarget);
end;


procedure TBitmapEncoderWMF.CrossFadeTo(const Targetbm: TBitmap;
                                        EffectTime: Integer;
                                        cropTarget: Boolean);
var
  StartTime, EndTime: Int64;
  alpha: byte;
  fact: Double;
  CF: TParallelizer;
  Index: Integer;
  bmOld, bmNew, bmTween: TBitmap;
  pOldStart, pNewStart, pTweenStart: PByte;

begin
  bmOld := TBitmap.Create();
  bmNew := TBitmap.Create();
  bmTween := TBitmap.Create();

  try
    bmOld.Assign(fBmRGBA);

    BitmapToRGBA(Targetbm,
                 bmNew,
                 cropTarget);

    bmTween.PixelFormat := pf32bit;

    bmTween.SetSize(fVideoWidth,
                    fVideoHeight);

    pOldStart := bmOld.ScanLine[fVideoHeight - 1];
    pNewStart := bmNew.ScanLine[fVideoHeight - 1];
    pTweenStart := bmTween.ScanLine[fVideoHeight - 1];

    CF.Init(fThreadPool.ThreadCount,
            4 * fVideoWidth * fVideoHeight);

    StartTime := fWriteStart;
    EndTime := StartTime + EffectTime * 10000;
    fact := 255 / 10000 / EffectTime;

    while EndTime - fWriteStart > 0 do
      begin
        alpha := Round((fact * (fWriteStart - StartTime)));

        for Index := 0 to fThreadPool.ThreadCount - 1 do
          fThreadPool.ResamplingThreads[Index].RunAnonProc(GetCrossFadeProc(CF,
                                                                            Index,
                                                                            alpha,
                                                                            pOldStart,
                                                                            pNewStart,
                                                                            pTweenStart));

        for Index := 0 to fThreadPool.ThreadCount - 1 do
          fThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE);

        bmRGBAToSampleBuffer(bmTween);

        WriteOneFrame(fWriteStart,
                      fSampleDuration);
      end;

  finally
    bmTween.Free;
    bmNew.Free;
    bmOld.Free;
  end;
end;


destructor TBitmapEncoderWMF.Destroy();
begin
  if fInitialized then
    Finalize;
  fThreadPool.Finalize;
  fBmRGBA.Free;
  inherited;
end;


// TimeStamp = Video-timestamp
function TBitmapEncoderWMF.WriteAudio(TimeStamp: Int64): HResult;
const
  ProcName = 'TBitmapEncoderWMF.WriteAudio';

var
  hr: HResult;
  ActualStreamIndex: DWord;
  flags: DWord;
  AudioTimestamp: Int64;
  AudioSampleDuration: Int64;
  pAudioSample: IMFSample;

label
  done;

begin
  hr := S_OK;
  // If audio is present write audio samples up to the Video-timestamp + fReadAhead
  while (fAudioTime + fAudioStart < TimeStamp + fReadAhead) and (not fAudioDone) do
    begin
      // pull a sample out of the audio source reader
      hr := pSourceReader.ReadSample(0, //fAudioStreamIndex, // get a sample from audio stream
                                     0, // no source reader controller flags
                                     @ActualStreamIndex, // get actual index of the stream
                                     @flags, // get flags for this sample
                                     @AudioTimestamp, // get the timestamp for this sample
                                     @pAudioSample); // get the actual sample
      if FAILED(hr) then
        Break;

      if ((flags and MF_SOURCE_READERF_STREAMTICK) <> 0) then
        begin
          hr := pSinkWriter.SendStreamTick(fSinkStreamIndexAudio,
                                           AudioTimestamp + fAudioStart);
          Continue;
        end;

      // To be on the safe side we check all flags for which
      // further reading would not make any sense
      // and set fAudioDone to True
      if ((flags and MF_SOURCE_READERF_ENDOFSTREAM) <> 0) or
        ((flags and MF_SOURCE_READERF_ERROR) <> 0) or
        ((flags and MF_SOURCE_READERF_NEWSTREAM) <> 0) or
        ((flags and MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) <> 0) or
        ((flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <> 0) then
        begin
          fAudioDone := True;
        end;

      if (pAudioSample <> nil) then
        begin

          hr := pAudioSample.GetSampleDuration(AudioSampleDuration);

          if SUCCEEDED(hr) then
            hr := pAudioSample.SetSampleTime(AudioTimeStamp + fAudioStart);

          if SUCCEEDED(hr) then
            hr := pAudioSample.SetSampleDuration(AudioSampleDuration);

          // send sample to sink-writer
          if SUCCEEDED(hr) then
            hr := pSinkWriter.WriteSample(fSinkStreamIndexAudio,
                                          pAudioSample);

          // new end of sample time
          fAudioTime := AudioTimestamp + AudioSampleDuration;
          Sleep(0);
        end;

      // fAudioDuration can be False!
      // if fAudioTime >= fAudioDuration then
      // fAudioDone := True;
      if fAudioDone then
        hr := pSinkWriter.NotifyEndOfSegment(fSinkStreamIndexAudio);

      // The following should not be necessary in Delphi,
      // since interfaces are automatically released,
      // but it fixes a memory leak when reading .mkv-files.
      SafeRelease(pAudioSample);
    end;

done:
  Result := hr;
end;


function TBitmapEncoderWMF.WriteOneFrame(TimeStamp: Int64;
                                         Duration: Int64): HResult;
const
  ProcName = 'TBitmapEncoderWMF.WriteOneFrame';

var
  hr: HResult;
  pSample: IMFSample;
  pSampleAudio: IMFSample;
  i, imax: DWord;
  DoAbort: Boolean;

label
  done;

begin

  if not fInitialized then
    begin
      hr := E_POINTER;
      goto done;
    end;

  // The encoder collects a number of video and audio samples in a "leaky bucket" before
  // writing a chunk of the file. There need to be enough audio-samples in the bucket, so
  // we read ahead in the audio-file, otherwise video-frames might be dropped in an attempt
  // to "match to audio" (?).
  if fWriteAudio then
    begin
      if (TimeStamp < fAudioStart) then
        // write silence to the audio stream
        begin
          if (TimeStamp = 0) then
            imax := 2
          else
            imax := 0;

          for i := 0 to imax do
            begin
              hr := MFCreateSample(pSampleAudio);
              if SUCCEEDED(hr) then
                hr := pSampleAudio.AddBuffer(pSampleBufferAudio);

              // write silence to the sinkwriter for 2 video frame durations ahead.
              if SUCCEEDED(hr) then
                hr := pSampleAudio.SetSampleTime(TimeStamp + (2 - imax + i) * Duration);

              if SUCCEEDED(hr) then
                hr := pSampleAudio.SetSampleDuration(Duration);

              if SUCCEEDED(hr) then
                hr := pSinkWriter.WriteSample(fSinkStreamIndexAudio,
                                              pSampleAudio);

              if SUCCEEDED(hr) then
                hr := pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio);

              if SUCCEEDED(hr) then
                SafeRelease(pSampleAudio);
            end;
        end
      else if (TimeStamp >= fAudioTime + fAudioStart - fReadAhead) and (not fAudioDone) then
        WriteAudio(TimeStamp);
  end;

  // Create a media sample and add the buffer to the sample.
  hr := MFCreateSample(pSample);
  if FAILED(hr) then
    goto done;

  hr := pSample.AddBuffer(pSampleBuffer);
  if FAILED(hr) then
    goto done;

  hr := pSample.SetSampleTime(TimeStamp);
  if FAILED(hr) then
    goto done;

  hr := pSample.SetSampleDuration(Duration);
  if FAILED(hr) then
    goto done;

  // Send the sample to the Sink Writer.
  hr := pSinkWriter.WriteSample(fstreamIndex,
                                pSample);
  if FAILED(hr) then
    goto done;

  Inc(fFrameCount);

  // Timestamp for the next frame
  fWriteStart := TimeStamp + Duration;
  fVideoTime := fWriteStart div 10000;

  // give the encoder-threads a chance to do their work.
  // Better use
  // Sleep(0);    // Sleep and application.ProcessMessages are not good practices to solve thread issues.
  // A better approach is to handle the thread messages in the current thread.
  HandleThreadMessages(GetCurrentThread, 100);

  if Assigned(fOnProgress) then
    if (fFrameCount mod 30 = 1) then
      begin
        DoAbort := False;
        fOnProgress(Self,
                    fFrameCount,
                    fVideoTime,
                    DoAbort);
        if DoAbort then
          Finalize();
      end;
done:
  if FAILED(hr) then
    begin
      raise Exception.CreateFmt('%s Procedure: %s Result: %s',
                                [SysErrorMessage(hr) + #13,
                                 ProcName + #13,
                                 IntToHex(hr, 8)]);
    end;
  Result := hr;
end;


function Interpolate(Z1,
                     Z2: TZoom;
                     t: Double): TZoom; inline;
begin
  t := StartSlowEndSlow(t);
  result.xCenter := t * (Z2.xCenter - Z1.xCenter) + Z1.xCenter;
  result.yCenter := t * (Z2.yCenter - Z1.yCenter) + Z1.yCenter;
  result.Radius := t * (Z2.Radius - Z1.Radius) + Z1.Radius;
end;


procedure TBitmapEncoderWMF.ZoomInOutTransition(const Sourcebm,
                                                Targetbm: TBitmap;
                                                ZoomSource,
                                                ZoomTarget: TZoom;
                                                EffectTime: Integer;
                                                cropSource,
                                                cropTarget: Boolean);
var
  DurMs: Integer;

begin
  AddFrame(Sourcebm, cropSource);
  DurMs := Round(1 / 10000 * fSampleDuration);
  ZoomInOutTransitionTo(Targetbm,
                        ZoomSource,
                        ZoomTarget,
                        EffectTime - DurMs,
                        cropTarget);
end;


procedure TBitmapEncoderWMF.ZoomInOutTransitionTo(const Targetbm: TBitmap;
                                                  ZoomSource: TZoom;
                                                  ZoomTarget: TZoom;
                                                  EffectTime: Integer;
                                                  cropTarget: Boolean);
var
  RGBASource,
  RGBATarget,
  RGBATweenSource,
  RGBATweenTarget,
  RGBATween: TBitmap;
  pSourceStart,
  pTargetStart,
  pTweenStart: PByte;
  ZIO: TParallelizer;
  StartTime,
  EndTime: Int64;
  fact: Double;
  alpha: Byte;
  t: Double;
  ZoomTweenSource,
  ZoomTweenTarget: TRectF;
  Index: Integer;

begin

  RGBASource := TBitmap.Create();
  RGBATarget := TBitmap.Create();
  RGBATweenSource := TBitmap.Create();
  RGBATweenTarget := TBitmap.Create();
  RGBATween := TBitmap.Create();

  try
    RGBASource.Assign(fBmRGBA);
    BitmapToRGBA(Targetbm,
                 RGBATarget,
                 cropTarget);

    RGBATween.PixelFormat := pf32bit;
    RGBATween.SetSize(fVideoWidth,
                      fVideoHeight);

    ZIO.Init(fThreadPool.ThreadCount,
             4 * fVideoWidth * fVideoHeight);

    StartTime := fWriteStart;
    EndTime := StartTime + EffectTime * 10000;
    fact := 1 / 10000 / EffectTime;

    while (EndTime - fWriteStart > 0) do
      begin
        t := fact * (fWriteStart - StartTime);
        ZoomTweenSource := Interpolate(_FullZoom,
                                       ZoomSource,
                                       t).ToRectF(fVideoWidth,
                                                  fVideoHeight);

        ZoomTweenTarget := Interpolate(ZoomTarget,
                                       _FullZoom,
                                       t).ToRectF(fVideoWidth,
                                                  fVideoHeight);

        uScaleWMF.ZoomResampleParallelThreads(fVideoWidth,
                                              fVideoHeight,
                                              RGBASource,
                                              RGBATweenSource,
                                              ZoomTweenSource,
                                              cfBilinear,
                                              0,
                                              amIgnore,
                                              @fThreadPool);

        uScaleWMF.ZoomResampleParallelThreads(fVideoWidth,
                                              fVideoHeight,
                                              RGBATarget,
                                              RGBATweenTarget,
                                              ZoomTweenTarget,
                                              cfBilinear,
                                              0,
                                              amIgnore,
                                              @fThreadPool);

        pSourceStart := RGBATweenSource.ScanLine[fVideoHeight - 1];
        pTargetStart := RGBATweenTarget.ScanLine[fVideoHeight - 1];
        pTweenStart := RGBATween.ScanLine[fVideoHeight - 1];

        alpha := Round(255 * t);

        for Index := 0 to fThreadPool.ThreadCount - 1 do
          fThreadPool.ResamplingThreads[Index].RunAnonProc(GetCrossFadeProc(ZIO,
                                                                            Index,
                                                                            alpha,
                                                                            pSourceStart,
                                                                            pTargetStart,
                                                                            pTweenStart));

        for Index := 0 to fThreadPool.ThreadCount - 1 do
          fThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE);

        bmRGBAToSampleBuffer(RGBATween);
        WriteOneFrame(fWriteStart,
                      fSampleDuration);
      end;

  finally
    RGBASource.Free();
    RGBATarget.Free();
    RGBATweenSource.Free();
    RGBATweenTarget.Free();
    RGBATween.Free();
  end;
end;


procedure TBitmapEncoderWMF.Freeze(EffectTime: Int64);
var
  hr: HResult;
  StartTime,
  EndTime: Int64;

begin

  StartTime := fWriteStart;
  EndTime := StartTime + EffectTime * 10000;

  while (fWriteStart < EndTime) do
    begin
      hr := WriteOneFrame(fWriteStart,
                          fSampleDuration);
      if SUCCEEDED(hr) then
        if ((fFrameCount mod fBrake) = fBrake - 1) then
          begin
            //Sleep(1);
            HandleThreadMessages(GetCurrentThread);
          end;
    end;
end;


{ TZoom }

function TZoom.ToRectF(Width: Integer;
                       Height: Integer): TRectF;
begin
  result.Left := Max((xCenter - Radius) * Width,
                     0);
  result.Right := Min((xCenter + Radius) * Width,
                      Width);
  result.Top := Max((yCenter - Radius) * Height,
                    0);
  result.Bottom := Min((yCenter + Radius) * Height,
                       Height);
end;


initialization

{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

end.
