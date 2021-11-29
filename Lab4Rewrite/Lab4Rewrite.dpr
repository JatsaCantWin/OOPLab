program Lab4Rewrite;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  Math, Windows,
  Vectors in 'Vectors.pas';

type
  IPersonState = interface(IInterface)
    function Handle: IPersonState;
  end;

  TPerson = class(TObject)
    private
      FState: IPersonState;
      FPosition: TVector;
      FMovementAngle: double;
      FMovementVelocity: double;
    public
      constructor Create(Ax, Ay, AMovementAngle: double);
      function Move: boolean;
      property Position: TVector read FPosition write FPosition;
      property State: IPersonState read FState write FState;
      function ToString: String; Override;
  end;

  TPeople = class(TObject)
    private
      FPeopleList: TList<TPerson>;
      constructor Create;
      class var
        FPeople: TPeople;
    public
      class function GetInstance: TPeople;
      procedure SpawnPerson;
      procedure HandleAll;
      procedure MoveAll;
      procedure ClearAll;
      procedure DrawAll;
      property PeopleList: TList<TPerson> read FPeopleList write FPeopleList;
  end;

  TPersonStateHealthy = class(TInterfacedObject, IPersonState)
    private
      FParent: TPerson;
      FNearbySickPeople: TDictionary<TPerson, uint8>;
    public
      constructor Create(AParent: TPerson);
      function Handle: IPersonState;
  end;

  TStateSickAsymptomatic = class(TInterfacedObject, IPersonState)
    private
      FTimeLeft: uint8;
    public
      constructor Create;
      function Handle: IPersonState;
  end;

  TStateSickSymptomatic = class(TInterfacedObject, IPersonState)
    private
      FTimeLeft: uint8;
    public
      constructor Create;
      function Handle: IPersonState;
  end;

  TPersonStateResistant = class(TInterfacedObject, IPersonState)
    public
      function Handle: IPersonState;
  end;

const
  SizeN = 3;
  SizeM = 3;
  MaxAngleVariation = 0.349066;
  MaxVelocityVariation = 0.01;
  MaxVelocity = 0.1;
  NewPersonFrequency = 25;
  InitialPopulation = 3;

{ TPerson }

constructor TPerson.Create(Ax, Ay, AMovementAngle: double);
begin
  FPosition:= TVector.Create(Ax, Ay);
  FMovementAngle:= AMovementAngle;
  FMovementVelocity:= Random*0.1;
  State:= TPersonStateHealthy.Create(Self);
end;

function TPerson.Move: boolean;
var
  MovementVector: TVector;
begin
  Result:= False;

  FMovementAngle:= FMovementAngle + Random*2*MaxAngleVariation - MaxAngleVariation;
  MovementVector:= TVector.Create(FMovementVelocity*cos(FMovementAngle), FMovementVelocity*sin(FMovementAngle));
  Position:= Position.Add(MovementVector);

  FMovementVelocity:= FMovementVelocity + Random*2*MaxVelocityVariation - MaxVelocityVariation;
  if FMovementVelocity > MaxVelocity then
    FMovementVelocity:= MaxVelocity;
  if (Position.X > SizeN) OR (Position.Y > SizeM) OR (Position.X < 0) OR (Position.Y < 0) then
  begin
//    if Random>0.5 then
//    begin
//      Result:= True;
//      Exit;
//    end;
    Position.X:= Min(Position.X, SizeN);
    Position.Y:= Min(Position.Y, SizeM);
    Position.X:= Max(Position.X, 0);
    Position.Y:= Max(Position.Y, 0);
    FMovementAngle:= FMovementAngle + 3.14159;
  end;
  if FMovementAngle > 6.28319 then
    FMovementAngle:= FMovementAngle - 6.28319;
end;

function TPerson.ToString: String;
begin
  Result:= Position.x.ToString + ' ' + Position.y.ToString + ' ' + RadToDeg(FMovementAngle).ToString;
end;

{ TPeople }

constructor TPeople.Create;
begin
  if FPeople = nil then
    FPeopleList:= TList<TPerson>.Create;
end;

class function TPeople.GetInstance: TPeople;
begin
  if FPeople = nil then
    FPeople:= TPeople.Create;
  Result:= FPeople;
end;

procedure TPeople.HandleAll;
var
  CurrentPerson: TPerson;
begin
  for CurrentPerson in FPeopleList do
    CurrentPerson.State:= CurrentPerson.State.Handle;
end;

procedure TPeople.MoveAll;
var
  CurrentPerson: TPerson;
begin
  for CurrentPerson in FPeopleList do
    if CurrentPerson.Move then
    begin
      FPeopleList.Remove(CurrentPerson);
      CurrentPerson.Free;
    end;
end;

procedure TPeople.DrawAll;
var
  CurrentPerson: TPerson;
  Console: Cardinal;
  CursorCoords: _COORD;
begin
  Console:= GetStdHandle(STD_OUTPUT_HANDLE);
  for CurrentPerson in FPeopleList do
  begin
    CursorCoords.X:= Round(CurrentPerson.Position.x+1); CursorCoords.Y:= Round(CurrentPerson.Position.Y+1);
    CursorCoords.X:= Max(CursorCoords.X, 1); CursorCoords.Y:= Max(CursorCoords.Y, 1);
    CursorCoords.X:= Min(CursorCoords.X, SizeN); CursorCoords.Y:= Min(CursorCoords.Y, SizeM);
    SetConsoleCursorPosition(Console, CursorCoords);
    if CurrentPerson.State is TPersonStateHealthy then
      SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY OR FOREGROUND_GREEN)
    else if CurrentPerson.State is TStateSickAsymptomatic then
      SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY OR FOREGROUND_BLUE)
    else if CurrentPerson.State is TStateSickSymptomatic then
      SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY OR FOREGROUND_RED)
    else
      SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY);
    Write('☺');
  end;
end;

procedure TPeople.ClearAll;
var
  CurrentPerson: TPerson;
  Console: Cardinal;
  CursorCoords: _COORD;
begin
  Console:= GetStdHandle(STD_OUTPUT_HANDLE);
  for CurrentPerson in FPeopleList do
  begin
    CursorCoords.X:= Round(CurrentPerson.Position.x+1); CursorCoords.Y:= Round(CurrentPerson.Position.Y+1);
    CursorCoords.X:= Max(CursorCoords.X, 1); CursorCoords.Y:= Max(CursorCoords.Y, 1);
    CursorCoords.X:= Min(CursorCoords.X, SizeN); CursorCoords.Y:= Min(CursorCoords.Y, SizeM);
    SetConsoleCursorPosition(Console, CursorCoords);
    Write(' ');
  end;
end;

procedure TPeople.SpawnPerson;
begin
  case Random(4) of
    0: FPeopleList.Add(TPerson.Create(0, Random*SizeM, 0));
    1: FPeopleList.Add(TPerson.Create(Random*SizeN, 0, 1.5708));
    2: FPeopleList.Add(TPerson.Create(SizeN, Random*SizeM, 3.14159));
    3: FPeopleList.Add(TPerson.Create(Random*SizeN, SizeM, 4.71239));
  end;
  if Random < 0.1 then
    if Random > 0.5 then
      FPeopleList.Last.State:= TStateSickAsymptomatic.Create
    else
      FPeopleList.Last.State:= TStateSickSymptomatic.Create;
end;

procedure DrawBorder;
var
  i, j: uint8;
begin
  Write('╔');
  for i := 1 to SizeN do
    Write('═');
  WriteLn('╗');
  for i := 1 to SizeM do
  begin
    Write('║');
    for j := 1 to SizeN do
      Write(' ');
    WriteLn('║');
  end;
  Write('╚');
  for i := 1 to SizeN do
    Write('═');
  WriteLn('╝');
end;

{ TPersonStateHealthy }

constructor TPersonStateHealthy.Create(AParent: TPerson);
begin
  FParent:= AParent;
  FNearbySickPeople:= TDictionary<TPerson, uint8>.Create;
end;

function TPersonStateHealthy.Handle: IPersonState;
var
  CurrentPerson: TPerson;
begin
  Result:= Self;
  for CurrentPerson in TPeople.GetInstance.PeopleList do
  begin
    if (CurrentPerson=FParent) OR ((CurrentPerson.State is TPersonStateHealthy) OR (CurrentPerson.State is TPersonStateResistant)) then
      Continue;
    if FNearbySickPeople.ContainsKey(CurrentPerson) then
    begin
      if FParent.Position.diff(CurrentPerson.Position).abs > 3 then
      begin
        FNearbySickPeople.Remove(CurrentPerson);
        Continue;
      end;
      if FNearbySickPeople[CurrentPerson] = 75 then
      begin
        if (CurrentPerson.State is TStateSickSymptomatic) OR (Random > 0.5) then
          if Random > 0.5 then
            Result:= TStateSickAsymptomatic.Create
          else
            Result:= TStateSickSymptomatic.Create;
      end
      else
        FNearbySickPeople[CurrentPerson]:= FNearbySickPeople[CurrentPerson] + 1;
    end
    else
      FNearbySickPeople.Add(CurrentPerson, 0);
  end;
end;

{ TStateSickAsymptomatic }

constructor TStateSickAsymptomatic.Create;
begin
  FTimeLeft:= Random(11)+20;
end;

function TStateSickAsymptomatic.Handle: IPersonState;
begin
  if FTimeLeft=0 then
    Result:= TPersonStateResistant.Create
  else
  begin
    Dec(FTimeLeft);
    Result:= Self;
  end;
end;

{ TStateSickSymptomatic }

constructor TStateSickSymptomatic.Create;
begin
  FTimeLeft:= Random(11)+20;
end;

function TStateSickSymptomatic.Handle: IPersonState;
begin
  if FTimeLeft=0 then
    Result:= TPersonStateResistant.Create
  else
  begin
    Dec(FTimeLeft);
    Result:= Self;
  end;
end;

{ TPersonStateResistant }

function TPersonStateResistant.Handle: IPersonState;
begin
  Result:= Self;
end;

var
  Console: Cardinal;
  CursorInfo: CONSOLE_CURSOR_INFO;
  i: uint8;

begin
  Randomize;
  Console:= GetStdHandle(STD_OUTPUT_HANDLE);
  CursorInfo.dwSize:= 100; CursorInfo.bVisible:= False;
  SetConsoleCursorInfo(Console, CursorInfo);
  DrawBorder;
  for i:= 1 to InitialPopulation do
    TPeople.GetInstance.SpawnPerson;
  i:= NewPersonFrequency;
  while True do
  begin
    TPeople.GetInstance.ClearAll;
    TPeople.GetInstance.MoveAll;
    TPeople.GetInstance.DrawAll;
    TPeople.GetInstance.HandleAll;
    Sleep(1);
    if i = 0 then
    begin
      i:= NewPersonFrequency;
      TPeople.GetInstance.SpawnPerson;
    end
    else
      Dec(i);
  end;
end.
