//
// Copyright: © FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: dlgAudioFormats.pas
// Kind: Pascal Unit
// Release date: 24-06-2023
// Language: ENU
//
// Revision Version: 3.1.5
// Description: Audio formats dialog where you can pick an encoder by it's profile.
//
// Company: FactoryX
// Intiator(s): Tony (maXcomX), Peter (OzShips), Ramyses De Macedo Rodrigues.
// Contributor(s): Tony Kalf (maXcomX)
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 20/07/2023 All                 Carmel release  SDK 10.0.22621.0 (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: Requires Windows 7 or higher.
//
// Related objects: -
// Related projects: MfPackX315
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.22621.0
//
// Todo: -
//
// =============================================================================
// Source: Parts of the Transcoding Example.
//
// Copyright (c) Microsoft Corporation. All rights reserved .
//==============================================================================
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
//==============================================================================
unit dlgAudioFormats;

interface

uses
  Winapi.Windows,
  WinApi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.Grids,
  WinApi.WinMM.MMReg,
  WinApi.MediaFoundationApi.MfApi,
  WinApi.MediaFoundationApi.MfMetLib,
  WinApi.MediaFoundationApi.MfUtils;

const
  CRLF = #13 + #10;


type
  TAudioFormatDlg = class(TForm)
    butOk: TButton;
    butCancel: TButton;
    Bevel1: TBevel;
    lblAudioFmt: TLabel;
    butSaveToFile: TButton;
    stxtBitRate: TStaticText;
    stxtSampleRate: TStaticText;
    stxtChannels: TStaticText;
    sgAudioEncoderFormats: TStringGrid;
    stxtBitsPerSample: TStaticText;
    stxtExtraInfo: TStaticText;
    Label1: TLabel;
    procedure butOkClick(Sender: TObject);
    procedure sgAudioEncoderFormatsClick(Sender: TObject);
    procedure rbSortAscClick(Sender: TObject);
    procedure rbSortDescClick(Sender: TObject);
    procedure butSaveToFileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure stxtBitRateClick(Sender: TObject);
    procedure stxtSampleRateClick(Sender: TObject);
    procedure stxtBitsPerSampleClick(Sender: TObject);
    procedure stxtChannelsClick(Sender: TObject);
    procedure butCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
    procedure Populate();
    procedure ResetAudioFormatArray();
    procedure SortSwitch(var Sender: TStaticText;
                         aTag: Integer;
                         aCol: Integer);
    // Grid sorting methods (Author: Peter Below)
    procedure SortStringgrid(byColumn: LongInt;
                             ascending: Boolean );
  public
    { Public declarations }
    iSelectedFormat: Integer;
    fAudioFormat: TGUID;
    fAudioFmts: TMFAudioFormatArray;
    fAudioCodecDescription: TStringList;

    function GetAudioFormats(const AudioFormat: TGuid): HResult;
    procedure GetFormatDescription(bGetAll: Boolean = False);
    procedure SaveAudioFmtsToFile();

  end;

var
  AudioFormatDlg: TAudioFormatDlg;


implementation

{$R *.dfm}

uses
  uDemoWMFMain;


procedure TAudioFormatDlg.butCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  iSelectedFormat := -1;
end;


procedure TAudioFormatDlg.butOkClick(Sender: TObject);
begin
  iSelectedFormat := StrToInt(sgAudioEncoderFormats.Cells[4,
                                                          sgAudioEncoderFormats.Row]);
  GetFormatDescription();
  ModalResult := mrOk;
end;


procedure TAudioFormatDlg.ResetAudioFormatArray();
var
  i: Integer;

begin
  // Reset the array
  if Length(fAudioFmts) > 0 then
    begin
      for i := 0 to Length(fAudioFmts) -1 do
        fAudioFmts[i].Reset;
      SetLength(fAudioFmts,
                0);
    end;
end;


procedure TAudioFormatDlg.sgAudioEncoderFormatsClick(Sender: TObject);
begin
  iSelectedFormat := StrToInt(sgAudioEncoderFormats.Cells[4,
                                                          sgAudioEncoderFormats.Row]);

  if (fAudioFmts[iSelectedFormat].wcSubFormat = 'MFAudioFormat_AAC') then
    begin
      //
      stxtExtraInfo.Caption := '             AAC PayLoad: ' + IntToStr(fAudioFmts[iSelectedFormat].unAACPayload) + CRLF +
                               ' AAC PayLoad Description: ' + string(fAudioFmts[iSelectedFormat].wsAACPayloadDescription) + CRLF +
                               '       AAC Profile Level: ' + IntToStr(fAudioFmts[iSelectedFormat].unAACProfileLevel) + CRLF +
                               ' AAC Profile Description: ' + string(fAudioFmts[iSelectedFormat].wsAACProfileLevelDescription);
    end;
end;


procedure TAudioFormatDlg.butSaveToFileClick(Sender: TObject);
begin
  SaveAudioFmtsToFile();
end;


procedure TAudioFormatDlg.FormDestroy(Sender: TObject);
begin
  fAudioCodecDescription.Free();
end;


procedure TAudioFormatDlg.FormShow(Sender: TObject);
begin
  sgAudioEncoderFormats.Row := 0;
  fAudioCodecDescription :=  TStringlist.Create();
  // Get all formats by given audioformat, supported by this OS.
  GetAudioFormats(DemoWMFMain.CurrentAudioCodec);
end;


function TAudioFormatDlg.GetAudioFormats(const AudioFormat: TGuid): HResult;
var
  hr: HResult;

begin
  ResetAudioFormatArray();
  // Get the encoder formats from the selected audioformat.
  hr := GetWinAudioEncoderFormats(AudioFormat,
                                  (MFT_ENUM_FLAG_LOCALMFT and not MFT_ENUM_FLAG_FIELDOFUSE) or MFT_ENUM_FLAG_SORTANDFILTER,
                                  fAudioFmts);
  if SUCCEEDED(hr) then
    Populate()
  else
    begin
      // Show a message
      //DebugMsg(SysErrorMessage(hr),
      //         hr);
      butCancel.Click();
    end;
  Result := hr;
end;


procedure TAudioFormatDlg.GetFormatDescription(bGetAll: Boolean = False);
var
  i: Integer;
  iBegin, iEnd: Integer;
  // Channel matrix.
  aLayout: string;
  aChannels: string;

begin
  fAudioCodecDescription.Clear();
  stxtExtraInfo.Caption := '';

  if bGetAll then
    begin
      iBegin := 0;
      iEnd := Length(fAudioFmts) -1;
    end
  else
    begin
      iBegin := iSelectedFormat;
      iEnd := iSelectedFormat;
    end;

  for i := iBegin to iEnd do
    begin

      if bGetAll then
        begin
          fAudioCodecDescription.Append(CRLF);
          fAudioCodecDescription.Append('================== Index: ' + IntToStr(i + 1) + ' ======================' + CRLF);
        end;

      fAudioCodecDescription.Append('            Major Format: ' + WideCharToString(fAudioFmts[i].wcMajorFormat));
      fAudioCodecDescription.Append('              Sub Format: ' + WideCharToString(fAudioFmts[i].wcSubFormat));
      fAudioCodecDescription.Append('                  FOURCC: ' + WideCharToString(fAudioFmts[i].wcFormatTag));
      fAudioCodecDescription.Append(CRLF);
      fAudioCodecDescription.Append('             Description: ' + WideCharToString(fAudioFmts[i].wsDescr));
      fAudioCodecDescription.Append(CRLF);

      case fAudioFmts[i].unChannels of
        1: fAudioCodecDescription.Append(Format('                Channels: %d (Mono)', [fAudioFmts[i].unChannels]));
        2: fAudioCodecDescription.Append(Format('                Channels: %d (Stereo)', [fAudioFmts[i].unChannels]));
        3: fAudioCodecDescription.Append(Format('                Channels: %d (2.1)', [fAudioFmts[i].unChannels]));
        5: fAudioCodecDescription.Append(Format('                Channels: %d (4.1)', [fAudioFmts[i].unChannels]));
        6: fAudioCodecDescription.Append(Format('                Channels: %d (5.1)', [fAudioFmts[i].unChannels]));
        7: fAudioCodecDescription.Append(Format('                Channels: %d (6.1)', [fAudioFmts[i].unChannels]));
        8: fAudioCodecDescription.Append(Format('                Channels: %d (7.1)', [fAudioFmts[i].unChannels]));
        else
          fAudioCodecDescription.Append(Format('                Channels: %d', [fAudioFmts[i].unChannels]));
      end; //case

      GetSpeakersLayOut(fAudioFmts[i].unChannelMask,
                        aLayout,
                        aChannels);

      fAudioCodecDescription.Append('          Channel Matrix: ' + aLayout);

      fAudioCodecDescription.Append('       Sample Rate (kHz): ' + FloatToStrF((fAudioFmts[i].unSamplesPerSec / 1000), ffGeneral, 4, 3));
      fAudioCodecDescription.Append(' Float Sample Rate (kHz): ' + FloatToStrF((fAudioFmts[i].dblFloatSamplePerSec / 1000), ffGeneral, 4, 3));
      fAudioCodecDescription.Append('       Samples Per Block: ' + IntToStr(fAudioFmts[i].unSamplesPerBlock));
      fAudioCodecDescription.Append('   Valid Bits Per Sample: ' + IntToStr(fAudioFmts[i].unValidBitsPerSample));
      fAudioCodecDescription.Append('         Bits Per Sample: ' + IntToStr(fAudioFmts[i].unBitsPerSample));
      fAudioCodecDescription.Append('         Block Alignment: ' + IntToStr(fAudioFmts[i].unBlockAlignment));
      fAudioCodecDescription.Append('          Bitrate (kbps): ' + FloatToStrF((fAudioFmts[i].unAvgBytesPerSec * 8) / 1000, ffGeneral, 4, 3));

      fAudioCodecDescription.Append(CRLF);

      if (fAudioFmts[i].wcSubFormat = 'MFAudioFormat_AAC') then
        begin
          fAudioCodecDescription.Append('             AAC PayLoad: ' + IntToStr(fAudioFmts[i].unAACPayload));
          fAudioCodecDescription.Append(' AAC PayLoad Description: ' + string(fAudioFmts[i].wsAACPayloadDescription));
          fAudioCodecDescription.Append('       AAC Profile Level: ' + IntToStr(fAudioFmts[i].unAACProfileLevel));
          fAudioCodecDescription.Append(' AAC Profile Description: ' + string(fAudioFmts[i].wsAACProfileLevelDescription));
        end;
    end;
end;


procedure TAudioFormatDlg.SaveAudioFmtsToFile();
begin
  GetFormatDescription(True);
  fAudioCodecDescription.SaveToFile(Format('Formats %s.txt',
                                           [WideCharToString(fAudioFmts[0].wcSubFormat)]));
end;


procedure TAudioFormatDlg.Populate();
var
  i: Integer;

begin
  // Clear the grid
  for i := 0 to sgAudioEncoderFormats.ColCount - 1 do
    sgAudioEncoderFormats.Cols[i].Clear;
  sgAudioEncoderFormats.RowCount := 1;

  lblAudioFmt.Caption := Format('%s%s',[fAudioFmts[0].wcFormatTag + #13 + #13,
                                        fAudioFmts[0].wsDescr]);

  // We need the following arrayvalues to show in the gridcells.

  // initialize the grid
  sgAudioEncoderFormats.ColCount := 5;
  sgAudioEncoderFormats.RowCount := 1;

  sgAudioEncoderFormats.ColWidths[0] := 100; // kbps
  sgAudioEncoderFormats.ColWidths[1] := 100; // Khz
  sgAudioEncoderFormats.ColWidths[2] := 100; // Bits per sample
  sgAudioEncoderFormats.ColWidths[3] := 100; // Channels
  sgAudioEncoderFormats.ColWidths[4] := -1;  // Hide last column

  // List compression formats.

  {$IFDEF ConditionalExpressions}
    {$IF CompilerVersion > 31.0}
       sgResolutions.BeginUpdate();
    {$IFEND}
  {$ENDIF}

  sgAudioEncoderFormats.RowCount := Length(fAudioFmts);

  for i := 0 to Length(fAudioFmts) -1 do
    begin

      // Calculate the bit rate:
      // Bit rate = Average Bytes Per Second * 8 / 1000
      sgAudioEncoderFormats.Cells[0, i] := FloatToStr(fAudioFmts[i].unAvgBytesPerSec * 8 / 1000) + #13;
      // Calculate the sampling rate:
      // Sample Rate (kHz) = Sample Rate (Hz) / 1000
      sgAudioEncoderFormats.Cells[1, i] := FloatToStr((fAudioFmts[i].unSamplesPerSec / 1000));
      sgAudioEncoderFormats.Cells[2, i] := Format('%d', [fAudioFmts[i].unBitsPerSample]);

      case fAudioFmts[i].unChannels of
        1: sgAudioEncoderFormats.Cells[3, i] := Format('%d (Mono)', [fAudioFmts[i].unChannels]);
        2: sgAudioEncoderFormats.Cells[3, i] := Format('%d (Stereo)', [fAudioFmts[i].unChannels]);
        6: sgAudioEncoderFormats.Cells[3, i] := Format('%d (5.1)', [fAudioFmts[i].unChannels]);
        7: sgAudioEncoderFormats.Cells[3, i] := Format('%d (6.1)', [fAudioFmts[i].unChannels]);
        8: sgAudioEncoderFormats.Cells[3, i] := Format('%d (7.1)', [fAudioFmts[i].unChannels]);
        else
          sgAudioEncoderFormats.Cells[3, i] := Format('%d', [fAudioFmts[i].unChannels]);
      end;

      // invisible
      sgAudioEncoderFormats.Cells[4, i] := IntToStr(i); // index!

    end;

  {$IFDEF ConditionalExpressions}
    {$IF CompilerVersion > 31.0}
       sgResolutions.EndUpdate();
    {$IFEND}
  {$ENDIF}
end;


procedure TAudioFormatDlg.rbSortAscClick(Sender: TObject);
begin
  SortStringgrid(0,
                 True);
end;


procedure TAudioFormatDlg.rbSortDescClick(Sender: TObject);
begin
  SortStringgrid(0,
                 False);
end;


procedure TAudioFormatDlg.SortStringgrid(byColumn: LongInt;
                                         ascending: Boolean );
  // Helpers
  procedure ExchangeGridRows(i: Integer;
                             j: Integer);
  var
    k: Integer;

  begin
    for k := 0 to sgAudioEncoderFormats.ColCount -1 Do
      sgAudioEncoderFormats.Cols[k].Exchange(i,
                                      j);
  end;

  procedure QuickSort(L: Integer;
                      R: Integer);
  var
    I: Integer;
    J: Integer;
    P: string;

  begin
    repeat
      I := L;
      J := R;
      P := sgAudioEncoderFormats.Cells[byColumn, (L + R) shr 1];
      repeat
        while (CompareStr(sgAudioEncoderFormats.Cells[byColumn, I],
                          P) < 0) do
          Inc(I);
        while (CompareStr(sgAudioEncoderFormats.Cells[byColumn, J],
                          P) > 0) do
          Dec(J);
        if (I <= J) then
          begin
            if (I <> J) Then
              ExchangeGridRows(I,
                               J);
            Inc(I);
            Dec(J);
          end;
      until (I > J);

      if (L < J) then
        QuickSort(L, J);
      L := I;
    until (I >= R);
  end;

  procedure InvertGrid();
  var
    i, j: Integer;

  begin
    i := sgAudioEncoderFormats.Fixedrows;
    j := sgAudioEncoderFormats.Rowcount -1;
    while (i < j) do
      begin
        ExchangeGridRows(i,
                         j);
        Inc(i);
        Dec(j);
      end; { While }
   end;

begin
  Screen.Cursor := crHourglass;
  sgAudioEncoderFormats.Perform(WM_SETREDRAW,
                         0,
                         0);
  try
    QuickSort(sgAudioEncoderFormats.FixedRows,
              sgAudioEncoderFormats.Rowcount-1 );
    if not ascending Then
      InvertGrid();
  finally
    sgAudioEncoderFormats.Perform(WM_SETREDRAW,
                 1,
                 0);
    sgAudioEncoderFormats.Refresh;
    Screen.Cursor := crDefault;
  end;
end;


procedure TAudioFormatDlg.SortSwitch(var Sender: TStaticText;
                                     aTag: Integer;
                                     aCol: Integer);
begin
  if Sender.Tag = 0 then
    begin
      SortStringgrid(aCol, True);
      Sender.Tag := 1;
    end
  else
    begin
      SortStringgrid(aCol, False);
      Sender.Tag := 0;
    end;
end;


procedure TAudioFormatDlg.stxtBitRateClick(Sender: TObject);
begin
  SortSwitch(stxtBitRate,
             stxtBitRate.Tag,
             0);
end;


procedure TAudioFormatDlg.stxtBitsPerSampleClick(Sender: TObject);
begin
  SortSwitch(stxtBitsPerSample,
             stxtBitsPerSample.Tag,
             2);
end;


procedure TAudioFormatDlg.stxtChannelsClick(Sender: TObject);
begin
  SortSwitch(stxtSampleRate,
             stxtSampleRate.Tag,
             3);
end;


procedure TAudioFormatDlg.stxtSampleRateClick(Sender: TObject);
begin
  SortSwitch(stxtSampleRate,
             stxtSampleRate.Tag,
             1);
end;


end.
