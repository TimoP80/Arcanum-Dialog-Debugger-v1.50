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
    btnLoadFolder: TButton;
    btnLoadDAT: TButton;
    btnClose: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadFolderClick(Sender: TObject);
    procedure btnLoadDATClick(Sender: TObject);
    procedure lbModulesDblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FEngine: TDialogEngine;
    FModuleRoot: string;
    procedure ScanModules;
    procedure LoadModule(const Path: string);
  public
    procedure BindEngine(Engine: TDialogEngine);
  end;

implementation

{$R *.dfm}

procedure TfrmModuleManager.FormCreate(Sender: TObject);
begin
  lbModules.Clear;
end;

procedure TfrmModuleManager.BindEngine(Engine: TDialogEngine);
begin
  FEngine := Engine;
end;

procedure TfrmModuleManager.ScanModules;
begin
  lbModules.Clear;
  if not DirectoryExists(FModuleRoot) then Exit;

  lbModules.Items.Add('Arcanum');
  for var Dir in TDirectory.GetDirectories(FModuleRoot) do
  begin
    var Name := TPath.GetFileName(Dir);
    if SameText(Name, 'Arcanum') then Continue;
    if TFile.Exists(TPath.Combine(Dir, Name + '.dat')) then
      lbModules.Items.Add(Name);
  end;
end;

procedure TfrmModuleManager.LoadModule(const Path: string);
var
  FullPath: string;
begin
  if SameText(Path, 'Arcanum') then
    FullPath := TPath.Combine(FModuleRoot, 'Arcanum')
  else
    FullPath := TPath.Combine(FModuleRoot, Path);

  if not DirectoryExists(FullPath) then
    raise Exception.CreateFmt('Module folder not found: %s', [FullPath]);

  LoadModuleData(FullPath);
  if Assigned(FEngine) then
  begin
    FEngine.LoadDialog('');
  end;

  ModalResult := mrOk;
end;

procedure TfrmModuleManager.btnLoadFolderClick(Sender: TObject);
var
  Folder: string;
begin
  if TDirectory.SelectDirectory('Select module folder', '', Folder) then
    LoadModule(Folder);
end;

procedure TfrmModuleManager.btnLoadDATClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    LoadModule(OpenDialog1.FileName);
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