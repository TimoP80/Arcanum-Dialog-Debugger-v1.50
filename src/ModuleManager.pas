unit ModuleManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.IOUtils,
  DialogEngine, ModuleLoader;

type
  TfrmModuleManager = class(TForm)
    pnlModules: TPanel;
    lbModules: TListBox;
    btnLoadModule: TButton;
    btnClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadModuleClick(Sender: TObject);
    procedure lbModulesDblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FEngine: TDialogEngine;
    FModuleRoot: string;
    FRootSet: Boolean;
    procedure ScanModules;
    procedure LoadModule(const Name: string);
  public
    procedure BindEngine(Engine: TDialogEngine);
    function SetModuleRoot(const Path: string): Boolean;
    property ModuleRoot: string read FModuleRoot;
  end;

implementation

{$R *.dfm}

procedure TfrmModuleManager.FormCreate(Sender: TObject);
begin
  lbModules.Clear;
  FRootSet := False;
end;

procedure TfrmModuleManager.BindEngine(Engine: TDialogEngine);
begin
  FEngine := Engine;
  if FRootSet then
    ScanModules;
end;

function TfrmModuleManager.SetModuleRoot(const Path: string): Boolean;
begin
  Result := False;
  if (Path = '') or (not DirectoryExists(Path)) then
    Exit;
  FModuleRoot := IncludeTrailingPathDelimiter(Path);
  FRootSet := True;
  Result := True;
  if Assigned(FEngine) then
    ScanModules;
end;

procedure TfrmModuleManager.ScanModules;
begin
  lbModules.Clear;
  if not FRootSet or (FModuleRoot = '') or (not DirectoryExists(FModuleRoot)) then Exit;

  lbModules.Items.Add('Arcanum');
  for var Dir in TDirectory.GetDirectories(FModuleRoot) do
  begin
    var Name := TPath.GetFileName(Dir);
    if SameText(Name, 'Arcanum') then Continue;
    if TFile.Exists(TPath.Combine(Dir, Name + '.dat')) then
      lbModules.Items.Add(Name);
  end;
end;

procedure TfrmModuleManager.LoadModule(const Name: string);
var
  Path: string;
begin
  if SameText(Name, 'Arcanum') then
    Path := TPath.Combine(FModuleRoot, 'Arcanum')
  else
    Path := TPath.Combine(FModuleRoot, Name);

  if not DirectoryExists(Path) then
    raise Exception.CreateFmt('Module folder not found: %s', [Path]);

  LoadModuleData(Path);
  if Assigned(FEngine) then
    FEngine.LoadDialog('');

  ModalResult := mrOk;
end;

procedure TfrmModuleManager.btnLoadModuleClick(Sender: TObject);
begin
  if lbModules.ItemIndex >= 0 then
    LoadModule(lbModules.Items[lbModules.ItemIndex]);
end;

procedure TfrmModuleManager.lbModulesDblClick(Sender: TObject);
begin
  if lbModules.ItemIndex >= 0 then
    LoadModule(lbModules.Items[lbModules.ItemIndex]);
end;

procedure TfrmModuleManager.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
