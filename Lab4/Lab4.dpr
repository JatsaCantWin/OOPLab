program Lab4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  Vectors in 'Vectors.pas';

type
  TPerson = class;

  TPersonState = class;

  IState = interface(IInterface)
    function Handle(): TPersonState;
  end;

  TPersonState = class(TInterfacedObject, IState)
    private
      FPerson: TPerson;
    public
      property Person: TPerson read FPerson write FPerson;
      function Handle(): TPersonState; virtual; abstract;
  end;

  TStateHealthy = class(TPersonState, IState)
    private
      FTicksNearSickPeople: TDictionary<TPerson, uint8>;
    public
      constructor Create();
      function Handle(): TPersonState;
      property TicksNearSickPeople: TDictionary<TPerson, uint8> read FTicksNearSickPeople write FTicksNearSickPeople;
  end;

  TStateSickAsymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint16;
    public
      constructor Create(ATimeUntilResistant: uint16);
      function Handle(): TPersonState;
      property TicksUntilResistand: uint16 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateSickSymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint16;
    public
      constructor Create(ATimeUntilResistant: uint16);
      function Handle(): TPersonState;
      property TicksUntilResistand: uint16 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateResistant = class(TPersonState, IState)
    public
      function Handle(): TPersonState;
  end;

  TMemento = class(TInterfacedObject)
    State: TClass;
    x: double;
    y: double;
  end;

  TSnapshot = class(TObject)
    private
      FTime: uint16;
      FMementoList: TList<TMemento>;
    public
      property Time: uint16 read FTime write FTime;
      property MementoList: TList<TMemento> read FMementoList write FMementoList;
      procedure PrintSnapshot();
  end;

  TPerson = class(TObject)
    private
      FPositionVector: TVector2D;
      FVelocityVector: TVectorVelocity;
      FState: TPersonState;
    public
      constructor Create(Ax, Ay: double; AState: TPersonState);
      property PositionVector: TVector2D read FPositionVector write FPositionVector;
      property VelocityVector: TVectorVelocity read FVelocityVector write FVelocityVector;
      property State: TPersonState read FState write FState;
      function GetMemento(): TMemento;
      procedure Move();
  end;

  TPopulation = class(TObject)
    private
      FPopulationList: TList<TPerson>;
      FSizeN: double;
      FSizeM: double;
      FTime: uint32;
      constructor Create;
      class var
        Population: TPopulation;
    public
      class function GetInstance(): TPopulation; static;
      procedure Update();
      procedure AddPerson(Ax, Ay: double; AState: TPersonState);
      function GetSnapshot(): TSnapshot;
      property PopulationList: TList<TPerson> read FPopulationList write FPopulationList;
      property SizeN: double read FSizeN write FSizeN;
      property SizeM: double read FSizeM write FSizeM;
      property Time: uint32 read FTime write FTime;
  end;

{ TPopulation }

procedure TPopulation.AddPerson(Ax, Ay: double; AState: TPersonState);
begin
  PopulationList.Add(TPerson.Create(Ax, Ay, AState));
end;

constructor TPopulation.Create;
begin
  inherited Create;
  PopulationList:= TList<TPerson>.Create();
end;

class function TPopulation.GetInstance: TPopulation;
begin
  if Population = nil then
      Population:= TPopulation.Create;
  Result:= Population;
end;

function TPopulation.GetSnapshot: TSnapshot;
var
  i: uint16;
begin
  Result:= TSnapshot.Create();
  Result.Time:= Population.GetInstance.Time;
  Result.MementoList:= TList<TMemento>.Create();
  for i:= 0 to PopulationList.Count-1 do
    Result.MementoList.Add(PopulationList[i].GetMemento);
end;

procedure TPopulation.Update;
var
  i: uint32;
  NewState: IState;
begin
  for i:= 0 to PopulationList.Count-1 do
  begin
    NewState:= PopulationList.Items[i].State.Handle;
    if NewState <> nil then
    begin
      //PopulationList.Items[i].State.Free;
      (NewState as TPersonState).Person:= PopulationList.Items[i];
      PopulationList.Items[i].State:= (NewState as TPersonState);
    end;
    PopulationList.Items[i].Move();
  end;
end;

{ TStateHealthy }

constructor TStateHealthy.Create;
begin
  inherited;
  TicksNearSickPeople:= TDictionary<TPerson, uint8>.Create();
end;

function TStateHealthy.Handle: TPersonState;
var
  i: int32;
  Difference: TVector2D;
begin
  Result:= nil;
  for i := 0 to TPopulation.GetInstance.PopulationList.Count-1 do
    if ((TPopulation.GetInstance.PopulationList.Items[i].State as TPersonState).ClassType = TStateSickAsymptomatic) OR
       ((TPopulation.GetInstance.PopulationList.Items[i].State as TPersonState).ClassType = TStateSickSymptomatic) then
          begin
            Difference:= Person.PositionVector.diff(TPopulation.GetInstance.PopulationList.Items[i].PositionVector);
            if Difference.abs() <= 3 then
            begin
              if TicksNearSickPeople.ContainsKey(TPopulation.GetInstance.PopulationList.Items[i]) then
                TicksNearSickPeople.AddOrSetValue(TPopulation.GetInstance.PopulationList.Items[i], TicksNearSickPeople[TPopulation.GetInstance.PopulationList.Items[i]]+1)
              else
                TicksNearSickPeople.Add(TPopulation.GetInstance.PopulationList.Items[i], 0)
            end
            else
              if TicksNearSickPeople.ContainsKey(TPopulation.GetInstance.PopulationList.Items[i]) then
                TicksNearSickPeople.Remove(TPopulation.GetInstance.PopulationList.Items[i]);
          end;
  for i:= 0 to TicksNearSickPeople.Keys.Count-1 do
    if ((TicksNearSickPeople.Keys.ToArray[i].State.ClassType = TStateSickAsymptomatic) AND (Random(2) = 0)) OR
        (TicksNearSickPeople.Keys.ToArray[i].State.ClassType = TStateSickSymptomatic) then
          if TicksNearSickPeople.Values.ToArray[i] >= 75 then
          begin
            TicksNearSickPeople.Remove(TicksNearSickPeople.Keys.ToArray[i]);
            if Random(2) = 0 then
              Result:= TStateSickSymptomatic.Create(Random(251)+500)
            else
              Result:= TStateSickAsymptomatic.Create(Random(251)+500);
          end
          else
            TicksNearSickPeople.Items[TicksNearSickPeople.Keys.ToArray[i]]:= TicksNearSickPeople.Items[TicksNearSickPeople.Keys.ToArray[i]] + 1;
end;

{ TStateSickAsymptomatic }

constructor TStateSickAsymptomatic.Create(ATimeUntilResistant: uint16);
begin
  inherited Create;
  TicksUntilResistand:= ATimeUntilResistant;
end;

function TStateSickAsymptomatic.Handle: TPersonState;
begin
  TicksUntilResistand:= TicksUntilResistand-1;
  if TicksUntilResistand = 0 then
    Result:= TStateResistant.Create();
end;

{ TStateSickSymptomatic }

constructor TStateSickSymptomatic.Create(ATimeUntilResistant: uint16);
begin
  inherited Create;
  TicksUntilResistand:= ATimeUntilResistant;
end;

function TStateSickSymptomatic.Handle: TPersonState;
begin
  TicksUntilResistand:= TicksUntilResistand-1;
  if TicksUntilResistand = 0 then
    Result:= TStateResistant.Create();
end;

{ TStateResistant }

function TStateResistant.Handle: TPersonState;
begin
  //
end;

{ TPerson }

constructor TPerson.Create(Ax, Ay: double; AState: TPersonState);
begin
  PositionVector:= TVector2D.Create(Ax, Ay);
  State:= AState;
  (State as TPersonState).Person:= Self;
  VelocityVector:= TVectorVelocity.Create(1, 1);
end;

function TPerson.GetMemento: TMemento;
begin
  Result:= TMemento.Create;
  Result.x:= PositionVector.x;
  Result.y:= PositionVector.y;
  Result.State:= (State as TPersonState).ClassType;
end;

procedure TPerson.Move;
begin
  VelocityVector.SetModule(Random*2.5);
  VelocityVector.SetAngle(Random*6.28319);
//  VelocityVector.SetAngle(VelocityVector.getAngle+(Random-0.5));
  PositionVector.x:= PositionVector.x + VelocityVector.x; PositionVector.y:= PositionVector.y + VelocityVector.y;
  if (abs(PositionVector.x) > TPopulation.GetInstance.FSizeN/2) OR (abs(PositionVector.y) > TPopulation.GetInstance.FSizeM/2) then
  begin
    VelocityVector.x:= VelocityVector.x*-2;
    VelocityVector.y:= VelocityVector.y*-2;
    PositionVector.x:= PositionVector.x + VelocityVector.x; PositionVector.y:= PositionVector.y + VelocityVector.y;
  end;
end;

{ TSnapshot }

procedure TSnapshot.PrintSnapshot;
var
  Current: TMemento;
begin
  WriteLn('Czas: ' + Time.ToString());
  for Current in MementoList do
    WriteLn(Current.x.ToString + ' ' + Current.y.ToString + ' ' + Current.State.ClassName);
end;

var
  i: uint32;

begin
  TPopulation.GetInstance.SizeN:= 20;
  TPopulation.GetInstance.SizeM:= 20;
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  for i := 0 to 30000 do
  begin
    TPopulation.GetInstance.Update;
    if (i mod 1000)=0 then
      TPopulation.GetInstance.GetSnapshot().PrintSnapshot;
    TPopulation.GetInstance.Time:= TPopulation.GetInstance.Time + 1;
  end;

  ReadLn(i);
end.
