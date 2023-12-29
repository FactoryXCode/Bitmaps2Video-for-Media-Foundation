unit uToolsWMF;

interface

uses
  {WinApi}
  WinApi.Windows,
  WinApi.Messages,
  {Use the wrapper version of WinApi.WIC.Wincodec}
  WinApi.Wincodec,
  {VCL}
  VCL.Graphics;

  /// <summary>
  /// Assigns a TWICImage to a TBitmap without setting its alphaformat to afDefined.
  /// A TWICImage can be used for fast decoding of image formats .jpg, .bmp, .png, .ico, .tif.
  /// </summary>
  procedure WICToBmp(const aWic: TWICImage;
                     const bmp: TBitmap);


  procedure HandleThreadMessages(AThread: THandle;
                                 AWait: Cardinal = INFINITE);

implementation


procedure WICToBmp(const aWic: TWICImage;
                   const bmp: TBitmap);
var
  LWicBitmap: IWICBitmapSource;
  Stride: Integer;
  w: Integer;
  h: Integer;
  Buffer: array of Byte;
  BitmapInfo: TBitmapInfo;

begin
  w := aWic.Width;
  h := aWic.Height;
  Stride := w * 4;
  SetLength(Buffer,
            Stride * h);

  WICConvertBitmapSource(GUID_WICPixelFormat32bppBGRA,
                         aWic.Handle,
                         LWicBitmap);

  LWicBitmap.CopyPixels(nil,
                        Stride,
                        Length(Buffer),
                        @Buffer[0]);

  FillChar(BitmapInfo,
           SizeOf(BitmapInfo),
                  0);
  BitmapInfo.bmiHeader.biSize := SizeOf(BitmapInfo);
  BitmapInfo.bmiHeader.biWidth := w;
  BitmapInfo.bmiHeader.biHeight := -h;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;

  bmp.SetSize(0,
              0); // erase pixels
  bmp.PixelFormat := pf32bit;

  // if the alphaformat was afDefined before, this is a good spot
  // for VCL.Graphics to do un-multiplication
  bmp.AlphaFormat := afIgnored;

  bmp.SetSize(w,
              h);
  SetDIBits(0,
            bmp.Handle,
            0,
            h,
            @Buffer[0],
            BitmapInfo,
            DIB_RGB_COLORS);
end;


procedure HandleThreadMessages(AThread: THandle;
                               AWait: Cardinal = INFINITE);
var
  oMsg: TMsg;

begin

  while (MsgWaitForMultipleObjects(1,
                                   AThread,
                                   False,
                                   AWait,
                                   QS_ALLINPUT) = WAIT_OBJECT_0 + 1) do
    begin
      PeekMessage(oMsg,
                  0,
                  0,
                  0,
                  PM_REMOVE);

      if oMsg.Message = WM_QUIT then
        Exit;

      TranslateMessage(oMsg);
      DispatchMessage(oMsg);
    end;
end;

end.
