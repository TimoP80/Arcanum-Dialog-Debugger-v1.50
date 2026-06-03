unit DialogEngine;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  DialogueParser, ArcanumSCRLib;

type
  TDialogEngine = class
  private
    FDialogNodes: TObjectList<TDialogueNode>;
    FCurrentNode: TDialogueNode;
    FGlobalFlags: TDictionary<Integer, Boolean>;
    FLocalFlags: TDictionary<Integer, Boolean>;
    FGlobalVars: TDictionary<Integer, Integer>;
    FLocalVars: TDictionary<Integer, Integer>;
    FStoryStates: TDictionary<Integer, Integer>;
    FPCVariables: TDictionary<Integer, Integer>;
    FPCFlags: TDictionary<Integer, Boolean>;
    FCounters: array[0..3] of Integer;

    FPlayerReputation: Integer;
    FPlayerReputations: TList<Integer>;
    FPlayerAlignment: Integer;
    FGold: Integer;
    FCharisma: Integer;
    FPerception: Integer;
    FPersuasion: Integer;
    FReaction: Integer;
    FStoryState: Integer;
    FQuests: TDictionary<Integer, Integer>;
    FRumors: TDictionary<Integer, Boolean>;
    FCurrentDaytime: Boolean;
    FPCBuzz: array[0..15] of Integer;
    FPlayerLevel: Integer;
    FMagicAptitude: Integer;
    FTechAptitude: Integer;
    FCurrentBuzz: Integer;
    FCurrentArea: Integer;
    FCurrentNPC: Integer;
  public
    type
      TSkill = (SkillBow = 0, SkillDodge, SkillMelee, SkillThrowing, SkillConcealment,
        SkillPickPocket, SkillSilentMove, SkillSpotTrap, SkillGambling, SkillHaggle,
        SkillHeal, SkillPersuasion, SkillRepair, SkillFirearms, SkillPickLock, SkillArmTrap);

    procedure ExecuteScript(const ScriptName: string);
    function EvaluateCondition(ConditionLine: scrline): Boolean;
    procedure ExecuteAction(ActionLine: scrline);
    function EvaluateTests(const TestStr: string): Boolean;
    procedure ExecuteResults(const ResultStr: string);
    function FindLineInNodes(TargetLine: Integer): TDialogueNode;

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadDialog(const FilePath: string);
    procedure SelectNode(const NodeName: string);
    procedure EvaluateOptions(out ValidOptions: TList<TPlayerOption>);

    procedure SelectOption(Option: TPlayerOption);

    property CurrentNode: TDialogueNode read FCurrentNode;
    property GlobalFlags: TDictionary<Integer, Boolean> read FGlobalFlags;
    property LocalFlags: TDictionary<Integer, Boolean> read FLocalFlags;
  end;

implementation

{ TDialogEngine }

constructor TDialogEngine.Create;
begin
  FDialogNodes := TObjectList<TDialogueNode>.Create;
  FGlobalFlags := TDictionary<Integer, Boolean>.Create;
  FLocalFlags := TDictionary<Integer, Boolean>.Create;
  FGlobalVars := TDictionary<Integer, Integer>.Create;
  FLocalVars := TDictionary<Integer, Integer>.Create;
  FStoryStates := TDictionary<Integer, Integer>.Create;
  FQuests := TDictionary<Integer, Integer>.Create;
  FPCVariables := TDictionary<Integer, Integer>.Create;
  FPCFlags := TDictionary<Integer, Boolean>.Create;
  FRumors := TDictionary<Integer, Boolean>.Create;
  FPlayerReputations := TList<Integer>.Create;

  FCounters[0] := 0;
  FCounters[1] := 0;
  FCounters[2] := 0;
  FCounters[3] := 0;

  FPlayerAlignment := 0;
  FGold := 500;
  FCharisma := 10;
  FPerception := 10;
  FPersuasion := 5;
  FReaction := 50;
  FStoryState := 0;
  FCurrentDaytime := True;
  FCurrentArea := 0;
  FCurrentNPC := 0;
  FCurrentBuzz := -1;
end;

destructor TDialogEngine.Destroy;
begin
  FPlayerReputations.Free;
  FRumors.Free;
  FPCFlags.Free;
  FPCVariables.Free;
  FQuests.Free;
  FStoryStates.Free;
  FLocalVars.Free;
  FGlobalVars.Free;
  FLocalFlags.Free;
  FGlobalFlags.Free;
  FDialogNodes.Free;
  inherited;
end;

procedure TDialogEngine.LoadDialog(const FilePath: string);
var
  Content: string;
  Strings: TStringList;
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File not found: %s', [FilePath]);

  Strings := TStringList.Create;
  try
    Strings.LoadFromFile(FilePath);
    Content := Strings.Text;
  finally
    Strings.Free;
  end;

  if Assigned(FDialogNodes) then
    FDialogNodes.Free;

  FDialogNodes := TDialogueParser.ParseDialogue(Content);

  if FDialogNodes.Count > 0 then
    FCurrentNode := FDialogNodes[0]
  else
    FCurrentNode := nil;
end;

procedure TDialogEngine.SelectNode(const NodeName: string);
var
  Node: TDialogueNode;
begin
  for Node in FDialogNodes do
  begin
    if SameText(Node.NodeName, NodeName) then
    begin
      FCurrentNode := Node;
      Exit;
    end;
  end;
  raise Exception.CreateFmt('Node not found: %s', [NodeName]);
end;

function TDialogEngine.FindLineInNodes(TargetLine: Integer): TDialogueNode;
var
  Node: TDialogueNode;
  LineNum: Integer;
begin
  for Node in FDialogNodes do
  begin
    if Node.LineMap.ContainsKey(TargetLine) then
    begin
      Result := Node;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TDialogEngine.EvaluateOptions(out ValidOptions: TList<TPlayerOption>);
var
  Option: TPlayerOption;
  GeneratedOpt: TGeneratedPlayerOption;
  Passed: Boolean;
begin
  ValidOptions := TList<TPlayerOption>.Create;
  if not Assigned(FCurrentNode) then Exit;

  for Option in FCurrentNode.PlayerOptions do
  begin
    Passed := EvaluateTests(Option.Tests);

    if Passed then
      ValidOptions.Add(Option);
  end;

  for GeneratedOpt in FCurrentNode.GeneratedOptions do
  begin
    case GeneratedOpt.GeneratedCode of
      'Q':
      begin
        Option.Text := Format('Q:%s', [GeneratedOpt.GeneratedParams]);
        Option.TargetLine := 0;
        Option.Tests := '';
        Option.Results := '';
        Option.IsGenerated := True;
        Option.GeneratedCode := GeneratedOpt.GeneratedCode;
        Option.GeneratedParams := GeneratedOpt.GeneratedParams;
        ValidOptions.Add(Option);
      end;
    end;
  end;
end;

procedure TDialogEngine.SelectOption(Option: TPlayerOption);
var
  NextNode: TDialogueNode;
  OptIndex: Integer;
begin
  ExecuteResults(Option.Results);

  if Option.TargetLine > 0 then
  begin
    NextNode := FindLineInNodes(Option.TargetLine);
    if Assigned(NextNode) then
      FCurrentNode := NextNode;
  end;
end;

procedure TDialogEngine.ExecuteScript(const ScriptName: string);
begin
end;

function TDialogEngine.EvaluateCondition(ConditionLine: scrline): Boolean;
begin
  Result := True;
  case ConditionLine.opcode of
    1: Result := FCurrentDaytime;
    2: Result := FGold >= ConditionLine.VarValue[1];
    3:
    begin
      if FLocalFlags.ContainsKey(ConditionLine.VarValue[0]) then
        Result := FLocalFlags[ConditionLine.VarValue[0]]
      else
        Result := False;
    end;
    4: Result := ConditionLine.VarValue[0] = ConditionLine.VarValue[1];
    5: Result := ConditionLine.VarValue[0] <= ConditionLine.VarValue[1];
    6:
    begin
      if FQuests.ContainsKey(ConditionLine.VarValue[0]) then
        Result := FQuests[ConditionLine.VarValue[0]] = ConditionLine.VarValue[1]
      else
        Result := False;
    end;
    7:
    begin
      if FQuests.ContainsKey(ConditionLine.VarValue[0]) then
        Result := FQuests[ConditionLine.VarValue[0]] = ConditionLine.VarValue[1]
      else
        Result := False;
    end;
    8: Result := False;
    9: Result := False;
    10: Result := True;
    11: Result := False;
    12: Result := False;
    13: Result := False;
    14: Result := False;
    15: Result := False;
    16: Result := False;
    17: Result := False;
    18: Result := False;
    19: Result := False;
    20: Result := False;
    21: Result := False;
    22: Result := False;
    23: Result := False;
    24: Result := False;
    25: Result := False;
    26: Result := True;
    27: Result := False;
    28: Result := True;
    29: Result := True;
    30: Result := False;
    31: Result := True;
    32: Result := False;
    33: Result := False;
    34: Result := False;
    35: Result := False;
    36: Result := True;
    37: Result := False;
    38: Result := False;
    39: Result := False;
    40:
    begin
      if FRumors.ContainsKey(ConditionLine.VarValue[0]) then
        Result := FRumors[ConditionLine.VarValue[0]]
      else
        Result := False;
    end;
    41:
    begin
      if FRumors.ContainsKey(ConditionLine.VarValue[0]) then
        Result := not FRumors[ConditionLine.VarValue[0]]
      else
        Result := True;
    end;
    42: Result := False;
    43:
    begin
      if FGlobalFlags.ContainsKey(ConditionLine.VarValue[0]) then
        Result := FGlobalFlags[ConditionLine.VarValue[0]]
      else
        Result := False;
    end;
    44: Result := False;
    45: Result := False;
    46: Result := False;
    47: Result := False;
    48: Result := False;
    49: Result := False;
    50: Result := False;
    51: Result := False;
    52: Result := False;
  end;
end;

procedure TDialogEngine.ExecuteAction(ActionLine: scrline);
begin
  case ActionLine.opcode of
    8: FLocalFlags.AddOrSetValue(ActionLine.VarValue[0], True);
    9: FLocalFlags.AddOrSetValue(ActionLine.VarValue[0], False);
    100: FGlobalFlags.AddOrSetValue(ActionLine.VarValue[0], True);
    101: FGlobalFlags.AddOrSetValue(ActionLine.VarValue[0], False);
  end;
end;

function TDialogEngine.EvaluateTests(const TestStr: string): Boolean;
var
  Tests: TArray<string>;
  TestPart: string;
  Opcode: string;
  Args: TArray<string>;
  Arg1, Arg2: Integer;
begin
  Result := True;
  if Trim(TestStr) = '' then Exit;

  Tests := TestStr.Split([','], TStringSplitOptions.ExcludeEmpty);
  for TestPart in Tests do
  begin
    Args := Trim(TestPart).Split([' '], TStringSplitOptions.ExcludeEmpty);
    if Length(Args) = 0 then Continue;

    Opcode := LowerCase(Trim(Args[0]));
    Arg1 := 0; Arg2 := 0;
    if Length(Args) >= 2 then Arg1 := StrToIntDef(Args[1], 0);
    if Length(Args) >= 3 then Arg2 := StrToIntDef(Args[2], 0);

    if Opcode = '$$' then
    begin
      if Arg1 > 0 then Result := FGold >= Arg1
      else Result := FGold <= -Arg1;
    end
    else if (Opcode = 'al') or (Opcode = 'na') then
    begin
      if Opcode = 'na' then Arg1 := -Arg1;
      if TestPart.Contains('<') then
        Result := FPlayerAlignment < Arg1
      else if TestPart.Contains('>') then
        Result := FPlayerAlignment > Arg1
      else if Arg1 > 0 then
        Result := FPlayerAlignment >= Arg1
      else
        Result := FPlayerAlignment <= -Arg1;
    end
    else if Opcode = 'ar' then
    begin
      if Arg1 > 0 then Result := FCurrentArea = Arg1
      else Result := FCurrentArea <> -Arg1;
    end
    else if Opcode = 'ch' then
    begin
      if Arg1 > 0 then Result := FCharisma >= Arg1
      else Result := FCharisma <= -Arg1;
    end
    else if Opcode = 'fo' then
    begin
      Result := (Arg1 = 1);
    end
    else if Opcode = 'gf' then
    begin
      if FGlobalFlags.ContainsKey(Arg1) then
        Result := FGlobalFlags[Arg1]
      else
        Result := False;
    end
    else if Opcode = 'gv' then
    begin
      if FGlobalVars.ContainsKey(Arg1) then
        Result := FGlobalVars[Arg1] = Arg2
      else
        Result := False;
    end
    else if Opcode = 'ha' then
    begin
      if Arg1 > 0 then Result := FPersuasion >= Arg1
      else Result := FPersuasion <= -Arg1;
    end
    else if Opcode = 'ia' then
    begin
      if Arg1 > 0 then Result := FCurrentArea = Arg1
      else Result := FCurrentArea <> -Arg1;
    end
    else if Opcode = 'in' then
    begin
      Result := False;
    end
    else if Opcode = 'lc' then
    begin
      Result := (Arg1 >= 0) and (Arg1 <= 3) and (FCounters[Arg1] = Arg2);
    end
    else if Opcode = 'le' then
    begin
      if Arg1 > 0 then Result := FPlayerLevel >= Arg1
      else Result := FPlayerLevel <= -Arg1;
    end
    else if Opcode = 'lf' then
    begin
      if (Arg1 >= 0) and (Arg1 <= 31) then
        Result := FLocalFlags.ContainsKey(Arg1) and FLocalFlags[Arg1]
      else
        Result := False;
    end
    else if Opcode = 'ma' then
    begin
      if Arg1 > 0 then Result := FMagicAptitude >= Arg1
      else Result := FMagicAptitude <= -Arg1;
    end
    else if Opcode = 'me' then
    begin
      Result := (Arg1 = 1);
    end
    else if Opcode = 'na' then
    begin
      if TestPart.Contains('<') then
        Result := FPlayerAlignment < Arg1
      else if TestPart.Contains('>') then
        Result := FPlayerAlignment > Arg1
      else if Arg1 > 0 then
        Result := FPlayerAlignment >= Arg1
      else
        Result := FPlayerAlignment <= -Arg1;
    end
    else if Opcode = 'ni' then
    begin
      Result := True;
    end
    else if Opcode = 'pa' then
    begin
      Result := False;
    end
    else if Opcode = 'pe' then
    begin
      if Arg1 > 0 then Result := FPerception >= Arg1
      else Result := FPerception <= -Arg1;
    end
    else if Opcode = 'pf' then
    begin
      if FPCFlags.ContainsKey(Arg1) then
        Result := FPCFlags[Arg1]
      else
        Result := False;
    end
    else if Opcode = 'ps' then
    begin
      if Arg1 > 0 then Result := FPersuasion >= Arg1
      else Result := FPersuasion <= -Arg1;
    end
    else if Opcode = 'pv' then
    begin
      if FPCVariables.ContainsKey(Arg1) then
        Result := FPCVariables[Arg1] = Arg2
      else
        Result := False;
    end
    else if Opcode = 'qa' then
    begin
      if not FQuests.ContainsKey(Arg1) then FQuests.Add(Arg1, 0);
      Result := FQuests[Arg1] >= Arg2;
    end
    else if Opcode = 'qb' then
    begin
      if not FQuests.ContainsKey(Arg1) then FQuests.Add(Arg1, 0);
      Result := FQuests[Arg1] <= Arg2;
    end
    else if Opcode = 'qu' then
    begin
      if not FQuests.ContainsKey(Arg1) then FQuests.Add(Arg1, 0);
      Result := FQuests[Arg1] = Arg2;
    end
    else if Opcode = 'ra' then
    begin
      if Arg1 > 0 then Result := True
      else Result := True;
    end
    else if Opcode = 're' then
    begin
      if Arg1 > 0 then Result := FReaction >= Arg1
      else Result := FReaction <= -Arg1;
    end
    else if Opcode = 'rp' then
    begin
      if Arg1 > 0 then
        Result := FPlayerReputations.Contains(Arg1)
      else
        Result := not FPlayerReputations.Contains(-Arg1);
    end
    else if Opcode = 'rq' then
    begin
      if FRumors.ContainsKey(Arg1) then
        Result := FRumors[Arg1]
      else
        Result := False;
    end
    else if Opcode = 'ru' then
    begin
      if Arg1 > 0 then
        Result := FRumors.ContainsKey(Arg1) and FRumors[Arg1]
      else
        Result := not (FRumors.ContainsKey(-Arg1) and FRumors[-Arg1]);
    end
    else if Opcode = 'sc' then
    begin
      Result := True;
    end
    else if Opcode = 'sk' then
    begin
      if Arg2 > 0 then Result := FPCBuzz[Arg1] >= Arg2
      else Result := FPCBuzz[Arg1] <= -Arg2;
    end
    else if Opcode = 'ss' then
    begin
      if Arg1 > 0 then Result := FStoryState >= Arg1
      else Result := FStoryState <= -Arg1;
    end
    else if Opcode = 'ta' then
    begin
      if Arg1 > 0 then Result := True
      else Result := True;
    end
    else if Opcode = 'tr' then
    begin
      Result := True;
    end
    else if Opcode = 'wa' then
    begin
      Result := (Arg1 = 1);
    end
    else if Opcode = 'wt' then
    begin
      Result := (Arg1 = 1);
    end
    else
    begin
      Result := True;
    end;

    if not Result then Exit;
  end;
end;

procedure TDialogEngine.ExecuteResults(const ResultStr: string);
var
  Results: TArray<string>;
  ResultPart: string;
  Opcode: string;
  Args: TArray<string>;
  Arg1, Arg2: Integer;
begin
  if Trim(ResultStr) = '' then Exit;

  Results := ResultStr.Split([','], TStringSplitOptions.ExcludeEmpty);
  for ResultPart in Results do
  begin
    Args := Trim(ResultPart).Split([' '], TStringSplitOptions.ExcludeEmpty);
    if Length(Args) = 0 then Continue;

    Opcode := LowerCase(Trim(Args[0]));
    Arg1 := 0; Arg2 := 0;
    if Length(Args) >= 2 then Arg1 := StrToIntDef(Args[1], 0);
    if Length(Args) >= 3 then Arg2 := StrToIntDef(Args[2], 0);

    if Opcode = '$$' then
    begin
      FGold := FGold + Arg1;
    end
    else if Opcode = 'al' then
    begin
      if ResultPart.Contains('<') then
        begin if FPlayerAlignment > Arg1 then FPlayerAlignment := Arg1 end
      else if ResultPart.Contains('>') then
        begin if FPlayerAlignment < Arg1 then FPlayerAlignment := Arg1 end
      else if ResultPart.Contains('+') or ResultPart.Contains('-') then
        FPlayerAlignment := FPlayerAlignment + Arg1
      else
        FPlayerAlignment := Arg1;
    end
    else if Opcode = 'ce' then
    begin
    end
    else if Opcode = 'co' then
    begin
    end
    else if Opcode = 'et' then
    begin
    end
    else if Opcode = 'fl' then
    begin
    end
    else if Opcode = 'fp' then
    begin
    end
    else if Opcode = 'gf' then
    begin
      FGlobalFlags.AddOrSetValue(Arg1, Arg2 <> 0);
    end
    else if Opcode = 'gv' then
    begin
      FGlobalVars.AddOrSetValue(Arg1, Arg2);
    end
    else if Opcode = 'ii' then
    begin
    end
    else if Opcode = 'in' then
    begin
    end
    else if Opcode = 'jo' then
    begin
    end
    else if Opcode = 'lc' then
    begin
      if (Arg1 >= 0) and (Arg1 <= 3) then
        FCounters[Arg1] := Arg2;
    end
    else if Opcode = 'lf' then
    begin
      FLocalFlags.AddOrSetValue(Arg1, Arg2 <> 0);
    end
    else if Opcode = 'lv' then
    begin
    end
    else if Opcode = 'mm' then
    begin
    end
    else if Opcode = 'nk' then
    begin
    end
    else if Opcode = 'np' then
    begin
    end
    else if Opcode = 'or' then
    begin
    end
    else if Opcode = 'pf' then
    begin
      FPCFlags.AddOrSetValue(Arg1, Arg2 <> 0);
    end
    else if Opcode = 'pv' then
    begin
      FPCVariables.AddOrSetValue(Arg1, Arg2);
    end
    else if Opcode = 'qu' then
    begin
      FQuests.AddOrSetValue(Arg1, Arg2);
    end
    else if Opcode = 're' then
    begin
      if ResultPart.Contains('<') then
        begin if FReaction > Arg1 then FReaction := Arg1 end
      else if ResultPart.Contains('>') then
        begin if FReaction < Arg1 then FReaction := Arg1 end
      else if ResultPart.Contains('+') or ResultPart.Contains('-') then
        FReaction := FReaction + Arg1
      else
        FReaction := Arg1;
    end
    else if Opcode = 'ri' then
    begin
    end
    else if Opcode = 'rp' then
    begin
      if Arg1 > 0 then
        FPlayerReputations.Add(Arg1)
      else if FPlayerReputations.Contains(-Arg1) then
        FPlayerReputations.Remove(-Arg1);
    end
    else if Opcode = 'rq' then
    begin
      FRumors.AddOrSetValue(Arg1, True);
    end
    else if Opcode = 'ru' then
    begin
      FRumors.AddOrSetValue(Arg1, True);
    end
    else if Opcode = 'sc' then
    begin
    end
    else if Opcode = 'so' then
    begin
    end
    else if Opcode = 'ss' then
    begin
      if Arg1 > FStoryState then
        FStoryState := Arg1;
    end
    else if Opcode = 'su' then
    begin
    end
    else if Opcode = 'tr' then
    begin
    end
    else if Opcode = 'uw' then
    begin
    end
    else if Opcode = 'wa' then
    begin
    end
    else if Opcode = 'xp' then
    begin
    end;
  end;
end;

end.