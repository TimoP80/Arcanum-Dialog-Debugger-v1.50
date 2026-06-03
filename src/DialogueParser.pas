unit DialogueParser;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, System.Generics.Collections;

type
  TPlayerOption = record
    Text: string;
    TargetLine: Integer;
    TargetNode: string;
    Script: string;
    Tests: string;
    Results: string;
    IsGenerated: Boolean;
    GeneratedCode: Char;
    GeneratedParams: string;
  end;

  TNPCLine = record
    LineNumber: Integer;
    MaleText: string;
    FemaleText: string;
  end;

  TGeneratedPlayerOption = record
    GeneratedCode: Char;
    GeneratedParams: string;
    DisplayIndex: Integer;
  end;

  TDialogueNode = class
    NodeName: string;
    Description: string;
    NPCLines: TList<TNPCLine>;
    PlayerOptions: TList<TPlayerOption>;
    GeneratedOptions: TList<TGeneratedPlayerOption>;
    LineMap: TDictionary<Integer, Integer>;
    constructor Create;
    destructor Destroy; override;
  end;

  TDialogueParser = class
  private
    class var FNodeCounter: Integer;
    class var FLineCounter: Integer;
    class function ParseNodeName(const CommentLine: string): string; static;
    class function ParseDescription(const CommentLine: string): string; static;
    class function ParseArcanumLine(const Line: string; out LineNumber: Integer;
      out IsNPC: Boolean; out NPCLine: TNPCLine; out Option: TPlayerOption;
      out Generated: TGeneratedPlayerOption): Boolean; static;
    class function ParseGeneratedCommand(const Text: string; out Code: Char;
      out Params: string): Boolean; static;
  public
    class function ParseDialogue(const Content: string): TObjectList<TDialogueNode>;
  end;

implementation

{ TDialogueNode }

constructor TDialogueNode.Create;
begin
  NPCLines := TList<TNPCLine>.Create;
  PlayerOptions := TList<TPlayerOption>.Create;
  GeneratedOptions := TList<TGeneratedPlayerOption>.Create;
  LineMap := TDictionary<Integer, Integer>.Create;
end;

destructor TDialogueNode.Destroy;
begin
  LineMap.Free;
  GeneratedOptions.Free;
  PlayerOptions.Free;
  NPCLines.Free;
  inherited;
end;

{ TDialogueParser }

class function TDialogueParser.ParseNodeName(const CommentLine: string): string;
var
  Match: TMatch;
begin
  Match := TRegEx.Match(CommentLine, '// NODE: (.+)');
  if Match.Success then
    Result := Match.Groups[1].Value
  else
  begin
    Inc(FNodeCounter);
    Result := Format('Node%.3d', [FNodeCounter]);
  end;
end;

class function TDialogueParser.ParseDescription(const CommentLine: string): string;
var
  Match: TMatch;
begin
  Match := TRegEx.Match(CommentLine, '// DESCRIPTION: (.+)');
  if Match.Success then
    Result := Match.Groups[1].Value
  else
    Result := '';
end;

class function TDialogueParser.ParseGeneratedCommand(const Text: string; out Code: Char;
  out Params: string): Boolean;
var
  Match: TMatch;
begin
  Result := False;
  Code := #0;
  Params := '';

  Match := TRegEx.Match(Text, '^([A-Z]):(.*)$');
  if Match.Success then
  begin
    Code := Match.Groups[1].Value[1];
    Params := Match.Groups[2].Value;
    Result := True;
  end;
end;

class function TDialogueParser.ParseArcanumLine(const Line: string; out LineNumber: Integer;
  out IsNPC: Boolean; out NPCLine: TNPCLine; out Option: TPlayerOption;
  out Generated: TGeneratedPlayerOption): Boolean;
var
  Parts: TArray<string>;
  I: Integer;
  Part: string;
  Match: TMatch;
  IsGen: Boolean;
  GenCode: Char;
  GenParams: string;
begin
  Result := False;
  IsNPC := False;
  IsGen := False;
  GenCode := #0;
  GenParams := '';
  FillChar(NPCLine, SizeOf(NPCLine), 0);
  FillChar(Option, SizeOf(Option), 0);
  FillChar(Generated, SizeOf(Generated), 0);

  Match := TRegEx.Match(Line, '^{\d+');
  if not Match.Success then Exit;

  LineNumber := 0;
  Match := TRegEx.Match(Line, '^{(\d+)');
  if Match.Success then
    LineNumber := StrToInt(Match.Groups[1].Value)
  else
    Exit;

  Parts := Line.Split(['}{'], TStringSplitOptions.ExcludeEmpty);

  if Length(Parts) >= 2 then
  begin
    if Length(Parts[1]) > 0 then
    begin
      case Parts[1].Trim(['{', '}'])[1] of
        'G', 'M': IsNPC := True;
      end;
    end;
  end
  else
    Exit;

  if IsNPC then
  begin
    NPCLine.LineNumber := LineNumber;
    if Length(Parts) > 2 then
      NPCLine.MaleText := Parts[2].Trim(['{', '}']);
    if Length(Parts) > 3 then
      NPCLine.FemaleText := Parts[3].Trim(['{', '}']);
    Result := True;
    Exit;
  end;

  Option.TargetLine := 0;
  Option.Tests := '';
  Option.Results := '';
  Option.IsGenerated := False;

  for I := 0 to High(Parts) do
  begin
    Part := Parts[I].Trim(['{', '}']);

    if I = 0 then
    begin
      if not TryStrToInt(Part, LineNumber) then
      begin
        Match := TRegEx.Match(Parts[0], '^{(\d+)$');
        if Match.Success then
          LineNumber := StrToInt(Match.Groups[1].Value);
      end;
    end
    else if I = 2 then
    begin
      if ParseGeneratedCommand(Part, GenCode, GenParams) then
      begin
        Option.IsGenerated := True;
        Option.GeneratedCode := GenCode;
        Option.GeneratedParams := GenParams;
        Option.Text := Part;
        IsGen := True;
      end
      else
        Option.Text := Part;
    end
    else if I = 3 then
    begin
      if not IsGen then
        Option.Text := Option.Text + Part;
    end
    else if I = 4 then
      Option.Tests := Part
    else if I = 5 then
    begin
      if not TryStrToInt(Part, Option.TargetLine) then
        Option.TargetLine := 0;
    end
    else if I = 6 then
      Option.Results := Part
    else if I >= 2 then
    begin
      if not IsGen and not ParseGeneratedCommand(Part, GenCode, GenParams) then
        Option.Text := Option.Text + Part;
    end;
  end;

  if (Option.Text <> '') or IsGen then
    Result := True;
end;

class function TDialogueParser.ParseDialogue(const Content: string): TObjectList<TDialogueNode>;
var
  Lines: TArray<string>;
  CurrentNode: TDialogueNode;
  Line: string;
  TrimmedLine: string;
  NodeName, Description: string;
  LineNumber: Integer;
  IsNPC: Boolean;
  NPCLine: TNPCLine;
  Option: TPlayerOption;
  Generated: TGeneratedPlayerOption;
  Parsed: Boolean;
begin
  Result := TObjectList<TDialogueNode>.Create(True);
  Lines := Content.Split([sLineBreak], TStringSplitOptions.ExcludeEmpty);

  CurrentNode := nil;
  FNodeCounter := 0;
  FLineCounter := 0;

  for Line in Lines do
  begin
    TrimmedLine := Line.Trim;

    if TrimmedLine.IsEmpty then
      Continue;

    if TrimmedLine.StartsWith('// NODE:') then
    begin
      if Assigned(CurrentNode) then
        Result.Add(CurrentNode);

      NodeName := ParseNodeName(TrimmedLine);
      CurrentNode := TDialogueNode.Create;
      CurrentNode.NodeName := NodeName;
    end
    else if TrimmedLine.StartsWith('// DESCRIPTION:') then
    begin
      if Assigned(CurrentNode) then
        CurrentNode.Description := ParseDescription(TrimmedLine);
    end
    else if Assigned(CurrentNode) and TrimmedLine.StartsWith('{') then
    begin
      Parsed := ParseArcanumLine(TrimmedLine, LineNumber, IsNPC, NPCLine, Option, Generated);
      if not Parsed then
        raise Exception.CreateFmt('Unrecognized dialogue line format: %s', [TrimmedLine]);

      if IsNPC then
      begin
        CurrentNode.NPCLines.Add(NPCLine);
        CurrentNode.LineMap.AddOrSetValue(LineNumber, CurrentNode.PlayerOptions.Count);
        FLineCounter := LineNumber;
      end
      else if Option.IsGenerated then
      begin
        Generated.DisplayIndex := CurrentNode.PlayerOptions.Count;
        CurrentNode.GeneratedOptions.Add(Generated);
        CurrentNode.LineMap.AddOrSetValue(LineNumber, CurrentNode.PlayerOptions.Count);
        FLineCounter := LineNumber;
      end
      else
      begin
        CurrentNode.PlayerOptions.Add(Option);
        CurrentNode.LineMap.AddOrSetValue(LineNumber, CurrentNode.PlayerOptions.Count - 1);
        FLineCounter := LineNumber;
      end;
    end;
  end;

  if Assigned(CurrentNode) then
    Result.Add(CurrentNode);
end;

end.