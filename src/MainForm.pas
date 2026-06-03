unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DialogEngine,
  DialogueParser, System.Generics.Collections;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    btnLoadDLG: TButton;
    OpenDialog1: TOpenDialog;
    lbNPCLine: TListBox;
    lbPlayerOptions: TListBox;
    Splitter1: TSplitter;
    pnlDebug: TPanel;
    mmoDebug: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadDLGClick(Sender: TObject);
    procedure lbPlayerOptionsDblClick(Sender: TObject);
  private
    FEngine: TDialogEngine;
    procedure RefreshUI;
    procedure LogDebug(const Msg: string);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FEngine := TDialogEngine.Create;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FEngine.Free;
end;

procedure TfrmMain.LogDebug(const Msg: string);
begin
  mmoDebug.Lines.Add(Msg);
end;

procedure TfrmMain.btnLoadDLGClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    try
      FEngine.LoadDialog(OpenDialog1.FileName);
      LogDebug('Loaded DLG: ' + OpenDialog1.FileName);
      RefreshUI;
    except
      on E: Exception do
        ShowMessage('Error loading DLG: ' + E.Message);
    end;
  end;
end;

procedure TfrmMain.RefreshUI;
var
  i: Integer;
  NPCLine: TNPCLine;
  ValidOptions: TList<TPlayerOption>;
  Opt: TPlayerOption;
begin
  lbNPCLine.Items.Clear;
  lbPlayerOptions.Items.Clear;

  if Assigned(FEngine.CurrentNode) then
  begin
    LogDebug('Current Node: ' + FEngine.CurrentNode.NodeName);
    for i := 0 to FEngine.CurrentNode.NPCLines.Count - 1 do
    begin
      NPCLine := FEngine.CurrentNode.NPCLines[i];
      lbNPCLine.Items.Add(Format('[%d] %s', [NPCLine.LineNumber, NPCLine.MaleText]));
    end;

    FEngine.EvaluateOptions(ValidOptions);
    try
      for i := 0 to ValidOptions.Count - 1 do
      begin
        Opt := ValidOptions[i];
        lbPlayerOptions.Items.AddObject(Format('[Target: %d] %s', [Opt.TargetLine, Opt.Text]), TObject(Opt.TargetLine));
      end;
    finally
      ValidOptions.Free;
    end;
  end;
end;

procedure TfrmMain.lbPlayerOptionsDblClick(Sender: TObject);
var
  OptIndex: Integer;
  Option: TPlayerOption;
begin
  if lbPlayerOptions.ItemIndex >= 0 then
  begin
    OptIndex := lbPlayerOptions.ItemIndex;
    if (OptIndex >= 0) and (OptIndex < FEngine.CurrentNode.PlayerOptions.Count) then
    begin
      Option := FEngine.CurrentNode.PlayerOptions[OptIndex];
      LogDebug(Format('Selected option [%d] jumping to line: %d', [OptIndex, Option.TargetLine]));
      FEngine.SelectOption(Option);
      RefreshUI;
    end
    else
    begin
      LogDebug('Selected option index out of range: ' + IntToStr(OptIndex));
    end;
  end;
end;

end.