program Lab5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  Windows;

const
  FirestationLocations: array [1..10] of array [1..2] of double =
  (
    (50.0599681, 19.9432917),
    (50.033417, 19.9358712),
    (50.0757205, 19.8873199),
    (50.0377162, 20.0057662),
    (50.0922302, 19.9220984),
    (50.0158412, 20.015671),
    (50.09411, 19.977434),
    (50.0773232, 20.0330777),
    (49.9683812, 19.799452),
    (50.0731309, 19.7859126)
  );

type

IState = interface(IInterface)
  function Handle: IState;
  function ToString: String;
end;

TStateReady = class(TInterfacedObject, IState)
  public
    function Handle: IState;
    function ToString: String; override;
end;

TStateEnroute = class(TInterfacedObject, IState)
  private
    Timeleft: uint32;
  public
    constructor Create;
    function Handle: IState;
    function ToString: String; override;
end;

TStateWorking = class(TInterfacedObject, IState)
  private
    Timeleft: uint32;
  public
    constructor Create;
    function Handle: IState;
    function ToString: String; override;
end;

TStateReturning = class(TInterfacedObject, IState)
  private
    Timeleft: uint32;
  public
    constructor Create;
    function Handle: IState;
    function ToString: String; override;
end;

IFiretruck = interface(IInterface)
  procedure Send;
end;

TFiretruck = class(TInterfacedObject, IFiretruck)
  private
    FState: IState;
  public
    constructor Create;
    procedure Send;
    procedure Update;
    property State: IState read FState write FState;
end;

TFirestation = class(TObject)
  private
    Fx: double;
    Fy: double;
    FFiretrucks: array [1..5] of TFiretruck;
    function GetFiretruck(Index: uint32): TFiretruck;
    procedure SetFiretruck(Index: uint32; Value: TFiretruck);
  public
    constructor Create(Ax, Ay: double);
    procedure UpdateFiretrucks;
    property x: double read Fx write Fx;
    property y: double read Fy write Fy;
                /// <link>aggregation</link>
                property Firetrucks[Index: uint32]: TFiretruck read GetFiretruck
                  write SetFiretruck;
                function GetReadyFiretruck: TFiretruck;
    function ToString: String; override;
end;

IFirestationIterator = interface(IInterface)
  function Next: TFirestation;
  function HasNext: boolean;
end;

IFirestations = interface(IInterface)
  function GetProximityIterator(Ax, Ay: double): IFirestationIterator;
end;

        TFirestations = class(TInterfacedObject, IFirestations)
        private
    FFirestationList: TList<TFirestation>;
    Constructor Create;
    class var
      Firestations: TFirestations;
        public
        var
                /// <link>aggregation</link>
                Field1: TFirestation;
                class function GetInstance: TFirestations;
    procedure NotifyAll;
    procedure AddObserver(AObserver: TFirestation);
    procedure RemoveObserver(AObserver: TFirestation);
    procedure UpdateFirestations;
    function GetProximityIterator(Ax, Ay: double): IFirestationIterator;
    function ToString: String; override;
end;

TFirestationProximityIterator = class(TInterfacedObject, IFirestationIterator)
  private
    FFirestationStack: TStack<TFirestation>;
  public
    constructor Create(ADistanceDictionary: TDictionary<TFirestation, double>);
    function Next: TFirestation;
    function HasNext: boolean;
end;

IStrategy = interface(IInterface)
  procedure Execute;
end;

TFireStrategy = class(TInterfacedObject, IStrategy)
  procedure Execute;
end;

TThreatStrategy = class(TInterfacedObject, IStrategy)
  procedure Execute;
end;

TContext = class(TObject)
  private
    class var
      FStrategy: IStrategy;
  public
                /// <link>aggregationByValue</link>
                class property Strategy: IStrategy write FStrategy;
                class procedure Execute;
end;

{ TStateReady }

function TStateReady.Handle: IState;
begin
  Result:= Self;
end;

function TStateReady.ToString: String;
begin
  Result:= 'Ready       ';
end;

{ TStateEnroute }

constructor TStateEnroute.Create;
begin
  Timeleft:= Random(4);
end;

function TStateEnroute.Handle: IState;
begin
  if TimeLeft = 0 then
  begin
    if Random(2)=0 then
      Result:= TStateWorking.Create
    else
      Result:= TStateReturning.Create;
  end
  else
  begin
    Dec(Timeleft);
    Result:= Self;
  end;
end;

function TStateEnroute.ToString: String;
begin
  Result:= Format('Enroute %3ds', [Timeleft]);
end;

{ TStateWorking }

constructor TStateWorking.Create;
begin
  Timeleft:= Random(21)+5;
end;

function TStateWorking.Handle: IState;
begin
  if TimeLeft = 0 then
    Result:= TStateReturning.Create
  else
  begin
    Dec(Timeleft);
    Result:= Self;
  end;
end;

function TStateWorking.ToString: String;
begin
  Result:= Format('Working %3ds', [Timeleft]);
end;

{ TStateReturning }

constructor TStateReturning.Create;
begin
  Timeleft:= Random(4);
end;

function TStateReturning.Handle: IState;
begin
  if TimeLeft = 0 then
    Result:= TStateReady.Create
  else
  begin
    Dec(Timeleft);
    Result:= Self;
  end;
end;

function TStateReturning.ToString: String;
begin
  Result:= Format('Retruning %1ds', [Timeleft]);
end;

{ TFiretruck }

constructor TFiretruck.Create;
begin
  State:= TStateReady.Create;
end;

procedure TFiretruck.Update;
begin
  State:= State.Handle;
end;

procedure TFiretruck.Send;
begin
  if State is TStateReady then
    State:= TStateEnroute.Create
  else
  begin
    WriteLn('Error: Tried to send a busy firetruck');
    ReadLn;
  end;
end;

{ TFirestation }

constructor TFirestation.Create(Ax, Ay: double);
var
  i: uint32;
begin
  x:= Ax;
  y:= Ay;
  for i:= Low(FFiretrucks) to High(FFiretrucks) do
    FFiretrucks[i]:= TFiretruck.Create;
end;

function TFirestation.GetFiretruck(Index: uint32): TFiretruck;
begin
  Result:= nil;
  if (Index >= Low(FFiretrucks)) AND (Index <= High(FFiretrucks)) then
    Result:= FFiretrucks[Index];
end;

procedure TFirestation.SetFiretruck(Index: uint32; Value: TFiretruck);
begin
  if (Index >= Low(FFiretrucks)) AND (Index <= High(FFiretrucks)) then
    FFiretrucks[Index]:= Value;
end;

procedure TFirestation.UpdateFiretrucks;
var
  CurrentFiretruck: TFiretruck;
begin
  for CurrentFiretruck in FFiretrucks do
    CurrentFiretruck.Update;
end;

function TFirestation.GetReadyFiretruck: TFiretruck;
var
  CurrentFiretruck: TFiretruck;
begin
  Result:= nil;
  for CurrentFiretruck in FFiretrucks do
    if CurrentFiretruck.State is TStateReady then
    begin
      Result:= CurrentFiretruck;
      Exit;
    end;
end;

function TFirestation.ToString: String;
var
  CurrentFiretruck: TFiretruck;
begin
  Result:= Format('| %5f | %5f | ', [x, y]);
  for CurrentFiretruck in FFiretrucks do
    Result:= Result+CurrentFiretruck.State.ToString + ' | ';

end;

{ TFirestations }

constructor TFirestations.Create;
begin
  if Firestations = nil then
    FFirestationList:= TList<TFirestation>.Create;
end;

class function TFirestations.GetInstance: TFirestations;
begin
  if Firestations = nil then
    Firestations:= TFirestations.Create;

  Result:= Firestations;
end;

procedure TFirestations.UpdateFirestations;
var
  CurrentFirestation: TFirestation;
begin
  for CurrentFirestation in FFirestationList do
    CurrentFirestation.UpdateFiretrucks;
end;

function TFirestations.GetProximityIterator(Ax, Ay: double): IFirestationIterator;
var
  DistanceDictionary: TDictionary<TFirestation, double>;
  CurrentFirestation: TFirestation;
begin
  Write(Format('(%2.6f, %2.6f)', [Ax, Ay]));
  DistanceDictionary:= TDictionary<TFirestation, double>.Create;
  for CurrentFirestation in FFirestationList do
    DistanceDictionary.Add(CurrentFirestation, Sqr(CurrentFirestation.x-Ax)+Sqr(CurrentFirestation.y-Ay));
  Result:= TFirestationProximityIterator.Create(DistanceDictionary);
  DistanceDictionary.Free;
end;

procedure TFirestations.NotifyAll;
begin
  if Random>0.7 then
    TContext.Strategy:= TFireStrategy.Create
  else
    TContext.Strategy:= TThreatStrategy.Create;
  Tcontext.Execute;
end;

procedure TFirestations.AddObserver(AObserver: TFirestation);
begin
  FFirestationList.Add(AObserver);
end;


procedure TFirestations.RemoveObserver(AObserver: TFirestation);
begin
  FFirestationList.Remove(AObserver);
end;

function TFirestations.ToString: String;
var
  CurrentFirestation: TFirestation;
begin
  Result:= '';
  for CurrentFirestation in FFirestationList do
    Result:= Result + CurrentFirestation.ToString + sLineBreak;
end;

{ TFirestationProximityIterator }

constructor TFirestationProximityIterator.Create(ADistanceDictionary: TDictionary<TFirestation, double>);
var
  TmpStack: TStack<TFirestation>;
  CurrentFirestation: TFirestation;
  DistanceNew, DistanceCurrent: double;
begin
  FFirestationStack:= TStack<TFirestation>.Create;
  for CurrentFirestation in ADistanceDictionary.Keys do
    FFirestationStack.Push(CurrentFirestation);

  TmpStack:= TStack<TFirestation>.Create;
  while FFirestationStack.Count > 0 do
  begin
    CurrentFirestation:= FFirestationStack.Pop;
    while (TmpStack.Count > 0) AND (ADistanceDictionary[TmpStack.Peek] > ADistanceDictionary[CurrentFirestation]) do
      FFirestationStack.Push(TmpStack.Pop);
    TmpStack.Push(CurrentFirestation);
  end;

  FFirestationStack.Free;
  FFirestationStack:= TmpStack;
end;

function TFirestationProximityIterator.Next: TFirestation;
begin
  Result:= FFirestationStack.Pop;
end;

function TFirestationProximityIterator.HasNext: boolean;
begin
  Result:= (FFirestationStack.Count > 0);
end;

{ TFireStrategy }

procedure TFireStrategy.Execute;
var
  ProximityIterator: IFirestationIterator;
  CurrentFirestation: TFirestation;
  i: uint32;
begin
  Write('Threat ');
  ProximityIterator:= TFirestations.GetInstance.GetProximityIterator(49.95855025648944+Random*0.19601375685, 19.688292482742394+Random*0.33641027594);
  i:= 3;
  while (i > 0) AND (ProximityIterator.HasNext) do
  begin
    CurrentFirestation:= ProximityIterator.Next;
    if CurrentFirestation.GetReadyFiretruck <> nil then
    begin
      CurrentFirestation.GetReadyFiretruck.Send;
      Dec(i);
    end;
  end;
end;

{ TThreatStrategy }

procedure TThreatStrategy.Execute;
var
  ProximityIterator: IFirestationIterator;
  CurrentFirestation: TFirestation;
  i: uint32;
begin
  Write('Fire ');
  ProximityIterator:= TFirestations.GetInstance.GetProximityIterator(49.95855025648944+Random*0.19601375685, 19.688292482742394+Random*0.33641027594);
  i:= 2;
  while (i > 0) AND (ProximityIterator.HasNext) do
  begin
    CurrentFirestation:= ProximityIterator.Next;
    if CurrentFirestation.GetReadyFiretruck <> nil then
    begin
      CurrentFirestation.GetReadyFiretruck.Send;
      Dec(i);
    end;
  end;
end;

{ TContext }

class procedure TContext.Execute;
begin
  FStrategy.Execute;
end;

var
  i: uint32;
  CurrentFirestation: TFirestation;
  Console: Cardinal;
  ZeroCoords: _COORD;
  CursorInfo: CONSOLE_CURSOR_INFO;

  AlarmChance: double = 0.2;

begin
  ZeroCoords.X:= 0; ZeroCoords.Y:= 0;
  CursorInfo.dwSize:= 100; CursorInfo.bVisible:= False;
  Console:= GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleCursorInfo(Console, CursorInfo);
  Randomize;
  for i:= Low(FirestationLocations) to High(FirestationLocations)  do
    TFirestations.GetInstance.AddObserver(TFirestation.Create(FirestationLocations[i][1], FirestationLocations[i][2]));
  i:= 0;
  while True do
  begin
    WriteLn(TFirestations.GetInstance.ToString);
    WriteLn(i.ToString + 's');
    if (Random<AlarmChance) then
      TFirestations.GetInstance.NotifyAll;
    WriteLn('                                    ');
    Sleep(100);
    SetConsoleCursorPosition(Console, ZeroCoords);
    Inc(i);
    TFirestations.GetInstance.UpdateFirestations;
  end;
end.
