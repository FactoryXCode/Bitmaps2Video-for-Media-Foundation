program DemoWMF;

uses
  Vcl.Forms,
  uDemoWMFMain in 'uDemoWMFMain.pas' {DemoWMFMain},
  dlgAudioFormats in 'dlgAudioFormats.pas' {AudioFormatDlg},
  AudioMftClass in 'Utilities\AudioMftClass.pas',
  Profiles in 'Utilities\Profiles.pas',
  uBitmaps2VideoWMF in 'Source\uBitmaps2VideoWMF.pas',
  uScaleCommonWMF in 'Source\uScaleCommonWMF.pas',
  uScaleWMF in 'Source\uScaleWMF.pas',
  uTransformer in 'Source\uTransformer.pas',
  uDirectoryTree in 'Utilities\uDirectoryTree.pas',
  uToolsWMF in 'Utilities\uToolsWMF.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDemoWMFMain, DemoWMFMain);
  Application.CreateForm(TAudioFormatDlg, AudioFormatDlg);
  Application.Run;
end.
