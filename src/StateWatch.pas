unit StateWatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, System.Generics.Collections,
  DialogEngine;

type
  TfrmStateWatch = class(TForm)
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
    procedure FormCreate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FEngine: TDialogEngine;
    procedure InitGrid(Grid: TStringGrid; const Captions: array of string);
    procedure RefreshFlagsVars;
    procedure RefreshState;
    procedure RefreshSkills;
    procedure RefreshQuests;
    procedure RefreshRumors;
  public
    procedure BindEngine(Engine: TDialogEngine);
  end;

implementation

{$R *.dfm}

procedure TfrmStateWatch.FormCreate(Sender: TObject);
begin
  InitGrid(gvFlags, ['Index', 'Value']);
  InitGrid(gvVars, ['Index', 'Value']);
  InitGrid(gvState, ['Property', 'Value']);
  InitGrid(gvSkills, ['Skill', 'Rank']);
  InitGrid(gvQuests, ['Quest', 'State']);
  InitGrid(gvRumors, ['Rumor', 'Known']);
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
begin
  if not Assigned(FEngine) then Exit;
  gvState.RowCount := 15;
  gvState.Cells[0, 1] := 'Gold';
  gvState.Cells[1, 1] := IntToStr(FEngine.Gold);
  gvState.Cells[0, 2] := 'Alignment';
  gvState.Cells[1, 2] := IntToStr(FEngine.Alignment);
  gvState.Cells[0, 3] := 'Charisma';
  gvState.Cells[1, 3] := IntToStr(FEngine.Charisma);
  gvState.Cells[0, 4] := 'Perception';
  gvState.Cells[1, 4] := IntToStr(FEngine.Perception);
  gvState.Cells[0, 5] := 'Persuasion';
  gvState.Cells[1, 5] := IntToStr(FEngine.Persuasion);
  gvState.Cells[0, 6] := 'Reaction';
  gvState.Cells[1, 6] := IntToStr(FEngine.Reaction);
  gvState.Cells[0, 7] := 'Story State';
  gvState.Cells[1, 7] := IntToStr(FEngine.StoryState);
  gvState.Cells[0, 8] := 'PC Level';
  gvState.Cells[1, 8] := IntToStr(FEngine.PCLevel);
  gvState.Cells[0, 9] := 'Magic Aptitude';
  gvState.Cells[1, 9] := IntToStr(FEngine.MagicAptitude);
  gvState.Cells[0, 10] := 'Tech Aptitude';
  gvState.Cells[1, 10] := IntToStr(FEngine.TechAptitude);
  gvState.Cells[0, 11] := 'Counter 0';
  gvState.Cells[1, 11] := IntToStr(FEngine.Counters[0]);
  gvState.Cells[0, 12] := 'Counter 1';
  gvState.Cells[1, 12] := IntToStr(FEngine.Counters[1]);
  gvState.Cells[0, 13] := 'Counter 2';
  gvState.Cells[1, 13] := IntToStr(FEngine.Counters[2]);
  gvState.Cells[0, 14] := 'Counter 3';
  gvState.Cells[1, 14] := IntToStr(FEngine.Counters[3]);
end;

procedure TfrmStateWatch.RefreshSkills;
var
  I: Integer;
  SkillNames: array[0..15] of string = (
    'Bow', 'Dodge', 'Melee', 'Throwing', 'Concealment', 'Pick Pocket',
    'Silent Move', 'Spot Trap', 'Gambling', 'Haggle', 'Heal', 'Persuasion',
    'Repair', 'Firearms', 'Pick Lock', 'Arm Trap');
begin
  if not Assigned(FEngine) then Exit;
  gvSkills.RowCount := 17;
  for I := 0 to 15 do
  begin
    gvSkills.Cells[0, I] := SkillNames[I];
    gvSkills.Cells[1, I] := IntToStr(FEngine.Skills[I]);
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