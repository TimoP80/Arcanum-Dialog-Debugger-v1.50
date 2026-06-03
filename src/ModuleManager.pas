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
    procedure ScanModules;
    procedure LoadModule(const Name: string);
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