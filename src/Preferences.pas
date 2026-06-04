unit Preferences;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.FileCtrl, System.IniFiles;

type
  TPreferences = class
  private
    FIniFile: TIniFile;
    FArcanumPath: string;
    FLastDLGFolder: string;
    FVerboseDebug: Boolean;
    FDebugLogging: Boolean;
    FLineNumberStep: Integer;
    function GetIniFileName: string;
    procedure LoadFromIni;
    procedure WriteToIni;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reload;
    procedure Save;
    property ArcanumPath: string read FArcanumPath write FArcanumPath;
    property LastDLGFolder: string read FLastDLGFolder write FLastDLGFolder;
    property VerboseDebug: Boolean read FVerboseDebug write FVerboseDebug;
    property DebugLogging: Boolean read FDebugLogging write FDebugLogging;
    property LineNumberStep: Integer read FLineNumberStep write FLineNumberStep;
  end;

  TfrmPreferences = class(TForm)
    pnlClient: TPanel;
    grpPaths: TGroupBox;
    lblArcanumPath: TLabel;
    edtArcanumPath: TEdit;
    btnBrowseArcanum: TButton;
    lblLastDLGFolder: TLabel;
    edtLastDLGFolder: TEdit;
    btnBrowseDLG: TButton;
    grpOptions: TGroupBox;
    chkVerboseDebug: TCheckBox;
    chkDebugLogging: TCheckBox;
    lblLineNumberStep: TLabel;
    edtLineNumberStep: TSpinEdit;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseArcanumClick(Sender: TObject);
    procedure btnBrowseDLGClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
  private
    FPrefs: TPreferences;
    procedure LoadControls;
    procedure ApplyControls;
  public
    class function Edit(var Prefs: TPreferences): Boolean;
  end;

implementation

{$R *.dfm}

{ TPreferences }

function TPreferences.GetIniFileName: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'DialogDebugger.ini';
end;

constructor TPreferences.Create;
begin
  inherited Create;
  FIniFile := TIniFile.Create(GetIniFileName);
  LoadFromIni;
end;

destructor TPreferences.Destroy;
begin
  FIniFile.Free;
  inherited Destroy;
end;

procedure TPreferences.LoadFromIni;
begin
  FArcanumPath := FIniFile.ReadString('Paths', 'ArcanumPath', '');
  FLastDLGFolder := FIniFile.ReadString('Paths', 'LastDLGFolder', '');
  FVerboseDebug := FIniFile.ReadBool('Debug', 'VerboseDebug', False);
  FDebugLogging := FIniFile.ReadBool('Debug', 'DebugLogging', True);
  FLineNumberStep := FIniFile.ReadInteger('Editor', 'LineNumberStep', 20);
end;

procedure TPreferences.WriteToIni;
begin
  FIniFile.WriteString('Paths', 'ArcanumPath', FArcanumPath);
  FIniFile.WriteString('Paths', 'LastDLGFolder', FLastDLGFolder);
  FIniFile.WriteBool('Debug', 'VerboseDebug', FVerboseDebug);
  FIniFile.WriteBool('Debug', 'DebugLogging', FDebugLogging);
  FIniFile.WriteInteger('Editor', 'LineNumberStep', FLineNumberStep);
end;

procedure TPreferences.Reload;
begin
  LoadFromIni;
end;

procedure TPreferences.Save;
begin
  WriteToIni;
end;

{ TfrmPreferences }

class function TfrmPreferences.Edit(var Prefs: TPreferences): Boolean;
var
  Dlg: TfrmPreferences;
begin
  Dlg := TfrmPreferences.Create(Application);
  try
    Dlg.FPrefs := Prefs;
    Dlg.LoadControls;
    Result := Dlg.ShowModal = mrOk;
    if Result then
      Dlg.ApplyControls;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmPreferences.FormCreate(Sender: TObject);
begin
  edtLineNumberStep.MinValue := 1;
  edtLineNumberStep.MaxValue := 1000;
  edtLineNumberStep.Value := 20;
end;

procedure TfrmPreferences.LoadControls;
begin
  edtArcanumPath.Text := FPrefs.ArcanumPath;
  edtLastDLGFolder.Text := FPrefs.LastDLGFolder;
  chkVerboseDebug.Checked := FPrefs.VerboseDebug;
  chkDebugLogging.Checked := FPrefs.DebugLogging;
  edtLineNumberStep.Value := FPrefs.LineNumberStep;
end;

procedure TfrmPreferences.ApplyControls;
begin
  FPrefs.ArcanumPath := Trim(edtArcanumPath.Text);
  FPrefs.LastDLGFolder := Trim(edtLastDLGFolder.Text);
  FPrefs.VerboseDebug := chkVerboseDebug.Checked;
  FPrefs.DebugLogging := chkDebugLogging.Checked;
  FPrefs.LineNumberStep := edtLineNumberStep.Value;
  FPrefs.Save;
end;

procedure TfrmPreferences.btnBrowseArcanumClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtArcanumPath.Text;
  if (Dir <> '') and (not System.SysUtils.DirectoryExists(Dir)) then
    Dir := ExtractFilePath(ParamStr(0));
  if SelectDirectory('Select Arcanum install directory', '', Dir) then
    edtArcanumPath.Text := Dir;
end;

procedure TfrmPreferences.btnBrowseDLGClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtLastDLGFolder.Text;
  if (Dir <> '') and (not System.SysUtils.DirectoryExists(Dir)) then
    Dir := ExtractFilePath(ParamStr(0));
  if SelectDirectory('Select last DLG folder', '', Dir) then
    edtLastDLGFolder.Text := Dir;
end;

procedure TfrmPreferences.btnOKClick(Sender: TObject);
begin
  ApplyControls;
  ModalResult := mrOk;
end;

procedure TfrmPreferences.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPreferences.btnApplyClick(Sender: TObject);
begin
  ApplyControls;
end;

end.
