unit StateWatch;

interface

uses
 Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.Grids, Vcl.StdCtrls, System.Generics.Collections,
  DialogEngine;

type
  TfrmStateWatch = class(TForm)
  private
    pcState: TPageControl;
    tsFlagsVars: TTabSheet;
    tsState: TTabSheet;
    tsSkills: TTabSheet;
    tsQuests: TTabSheet;
    tsRumors: TTabSheet;
    gvFlags: TStringGrid;
    gvVars: TStringGrid;
    gvState: TStringGrid;
    gvQuests: TStringGrid;
    gvRumors: TStringGrid;
    gvSkills: TStringGrid;
    btnRefresh: TButton;
    btnClose: TButton;
    FEngine: TDialogEngine;
    procedure InitGrid(Grid: TStringGrid; const Captions: array of string);
    procedure RefreshFlagsVars;
    procedure RefreshState;
    procedure RefreshSkills;
    procedure RefreshQuests;
    procedure RefreshRumors;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BindEngine(Engine: TDialogEngine);
  end;

implementation

uses System.Math;

const
  SkillNames: array[0..15] of string = (
    'Bow', 'Dodge', 'Melee', 'Throwing', 'Concealment', 'Pick Pocket',
    'Silent Move', 'Spot Trap', 'Gambling', 'Haggle', 'Heal', 'Persuasion',
    'Repair', 'Firearms', 'Pick Lock', 'Arm Trap');

{ TfrmStateWatch }

constructor TfrmStateWatch.Create(AOwner: TComponent);
var
  L: Integer;
begin
  inherited Create(AOwner);
  Caption := 'State Watch';
  Width := 840;
  Height := 560;

  pcState := TPageControl.Create(Self);
  pcState.Parent := Self;
  pcState.Left := 8;
  pcState.Top := 8;
  pcState.Width := 804;
  pcState.Height := 440;

  tsFlagsVars := TTabSheet.Create(pcState);
  tsFlagsVars.PageControl := pcState;
  tsFlagsVars.Caption := 'Flags / Vars';

  tsState := TTabSheet.Create(pcState);
  tsState.PageControl := pcState;
  tsState.Caption := 'State';

  tsSkills := TTabSheet.Create(pcState);
  tsSkills.PageControl := pcState;
  tsSkills.Caption := 'Skills';

  tsQuests := TTabSheet.Create(pcState);
  tsQuests.PageControl := pcState;
  tsQuests.Caption := 'Quests';

  tsRumors := TTabSheet.Create(pcState);
  tsRumors.PageControl := pcState;
  tsRumors.Caption := 'Rumors';

  gvFlags := TStringGrid.Create(Self);
  gvFlags.Parent := tsFlagsVars;
  gvFlags.Align := alClient;

  gvVars := TStringGrid.Create(Self);
  gvVars.Parent := tsFlagsVars;
  gvVars.Align := alRight;
  gvVars.Left := 400;
  gvVars.Width := 390;

  gvState := TStringGrid.Create(Self);
  gvState.Parent := tsState;
  gvState.Align := alClient;

  gvSkills := TStringGrid.Create(Self);
  gvSkills.Parent := tsSkills;
  gvSkills.Align := alClient;

  gvQuests := TStringGrid.Create(Self);
  gvQuests.Parent := tsQuests;
  gvQuests.Align := alClient;

  gvRumors := TStringGrid.Create(Self);
  gvRumors.Parent := tsRumors;
  gvRumors.Align := alClient;

  btnRefresh := TButton.Create(Self);
  btnRefresh.Parent := Self;
  btnRefresh.Left := 520;
  btnRefresh.Top := 460;
  btnRefresh.Width := 120;
  btnRefresh.Height := 28;
  btnRefresh.Caption := 'Refresh';
  btnRefresh.OnClick := btnRefreshClick;

  btnClose := TButton.Create(Self);
  btnClose.Parent := Self;
  btnClose.Left := 656;
  btnClose.Top := 460;
  btnClose.Width := 120;
  btnClose.Height := 28;
  btnClose.Caption := 'Close';
  btnClose.OnClick := btnCloseClick;

  InitGrid(gvFlags, ['Index', 'Value']);
  InitGrid(gvVars, ['Index', 'Value']);
  InitGrid(gvState, ['Property', 'Value']);
  InitGrid(gvSkills, ['Skill', 'Rank']);
  InitGrid(gvQuests, ['Quest', 'State']);
  InitGrid(gvRumors, ['Rumor', 'Known']);
end;

destructor TfrmStateWatch.Destroy;
begin
  inherited;
end;

procedure TfrmStateWatch.InitGrid(Grid: TStringGrid; const Captions: array of string);
var
  I: Integer;
begin
  Grid.ColCount := Length(Captions);
  Grid.RowCount := 2;
  for I := 0 to High(Captions) do
    Grid.Cols[I].Clear;
  for I := 0 to High(Captions) do
    Grid.Cells[I, 0] := Captions[I];
end;

procedure TfrmStateWatch.BindEngine(Engine: TDialogEngine);
begin
  FEngine := Engine;
  if Assigned(FEngine) then
    btnRefreshClick(nil);
end;

procedure TfrmStateWatch.RefreshFlagsVars;
var
  I: Integer;
begin
  if not Assigned(FEngine) then Exit;
  gvFlags.RowCount := Max(2, FEngine.GlobalFlags.Count + 1);
  gvFlags.Rows[1].Clear;
  gvFlags.RowCount := 2;
  for I := 0 to FEngine.GlobalFlags.Count - 1 do
  begin
    if gvFlags.RowCount <= I + 1 then
      gvFlags.RowCount := I + 2;
    gvFlags.Cells[0, I + 1] := IntToStr(FEngine.GlobalFlags.Keys.ToArray[I]);
    gvFlags.Cells[1, I + 1] := BoolToStr(FEngine.GlobalFlags.Values.ToArray[I], True);
  end;

  gvVars.RowCount := Max(2, FEngine.GlobalVars.Count + 1);
  gvVars.Rows[1].Clear;
  gvVars.RowCount := 2;
  for I := 0 to FEngine.GlobalVars.Count - 1 do
  begin
    if gvVars.RowCount <= I + 1 then
      gvVars.RowCount := I + 2;
    gvVars.Cells[0, I + 1] := IntToStr(FEngine.GlobalVars.Keys.ToArray[I]);
    gvVars.Cells[1, I + 1] := IntToStr(FEngine.GlobalVars.Values.ToArray[I]);
  end;
end;

procedure TfrmStateWatch.RefreshState;
var
  I: Integer;
begin
  if not Assigned(FEngine) then Exit;
  I := 1;
  gvState.RowCount := 15;
  gvState.Cells[0, I] := 'Gold';
  gvState.Cells[1, I] := IntToStr(FEngine.Gold); Inc(I);
  gvState.Cells[0, I] := 'Alignment';
  gvState.Cells[1, I] := IntToStr(FEngine.Alignment); Inc(I);
  gvState.Cells[0, I] := 'Charisma';
  gvState.Cells[1, I] := IntToStr(FEngine.Charisma); Inc(I);
  gvState.Cells[0, I] := 'Perception';
  gvState.Cells[1, I] := IntToStr(FEngine.Perception); Inc(I);
  gvState.Cells[0, I] := 'Persuasion';
  gvState.Cells[1, I] := IntToStr(FEngine.Persuasion); Inc(I);
  gvState.Cells[0, I] := 'Reaction';
  gvState.Cells[1, I] := IntToStr(FEngine.Reaction); Inc(I);
  gvState.Cells[0, I] := 'Story State';
  gvState.Cells[1, I] := IntToStr(FEngine.StoryState); Inc(I);
  gvState.Cells[0, I] := 'PC Level';
  gvState.Cells[1, I] := IntToStr(FEngine.PCLevel); Inc(I);
  gvState.Cells[0, I] := 'Magic Aptitude';
  gvState.Cells[1, I] := IntToStr(FEngine.MagicAptitude); Inc(I);
  gvState.Cells[0, I] := 'Tech Aptitude';
  gvState.Cells[1, I] := IntToStr(FEngine.TechAptitude); Inc(I);
  gvState.Cells[0, I] := 'Counter 0';
  gvState.Cells[1, I] := IntToStr(FEngine.Counter[0]); Inc(I);
  gvState.Cells[0, I] := 'Counter 1';
  gvState.Cells[1, I] := IntToStr(FEngine.Counter[1]); Inc(I);
  gvState.Cells[0, I] := 'Counter 2';
  gvState.Cells[1, I] := IntToStr(FEngine.Counter[2]); Inc(I);
  gvState.Cells[0, I] := 'Counter 3';
  gvState.Cells[1, I] := IntToStr(FEngine.Counter[3]); Inc(I);
end;

procedure TfrmStateWatch.RefreshSkills;
var
  I: Integer;
begin
  if not Assigned(FEngine) then Exit;
  gvSkills.RowCount := 17;
  for I := 0 to 15 do
  begin
    gvSkills.Cells[0, I] := SkillNames[I];
    gvSkills.Cells[1, I] := IntToStr(FEngine.Skill[I]);
  end;
end;

procedure TfrmStateWatch.RefreshQuests;
var
  I: Integer;
  Keys: TArray<Integer>;
begin
  if not Assigned(FEngine) then Exit;
  Keys := FEngine.Quests.Keys.ToArray;
  TArray.Sort<Integer>(Keys);
  gvQuests.RowCount := Max(2, Length(Keys) + 1);
  for I := 0 to High(Keys) do
  begin
    gvQuests.Cells[0, I + 1] := IntToStr(Keys[I]);
    gvQuests.Cells[1, I + 1] := IntToStr(FEngine.Quests[Keys[I]]);
  end;
end;

procedure TfrmStateWatch.RefreshRumors;
var
  I: Integer;
  Keys: TArray<Integer>;
begin
  if not Assigned(FEngine) then Exit;
  Keys := FEngine.Rumors.Keys.ToArray;
  TArray.Sort<Integer>(Keys);
  gvRumors.RowCount := Max(2, Length(Keys) + 1);
  for I := 0 to High(Keys) do
  begin
    gvRumors.Cells[0, I + 1] := IntToStr(Keys[I]);
    gvRumors.Cells[1, I + 1] := BoolToStr(FEngine.Rumors[Keys[I]], True);
  end;
end;

procedure TfrmStateWatch.btnRefreshClick(Sender: TObject);
begin
  RefreshFlagsVars;
  RefreshState;
  RefreshSkills;
  RefreshQuests;
  RefreshRumors;
end;

procedure TfrmStateWatch.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.