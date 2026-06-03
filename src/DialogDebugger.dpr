program DialogDebugger;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  DialogEngine in 'DialogEngine.pas',
  DialogueParser in 'DialogueParser.pas',
  ArcanumSCRLib in 'ArcanumSCRLib.pas',



begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
