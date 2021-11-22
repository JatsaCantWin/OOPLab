program Lab4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  Vectors in 'Vectors.pas';

type
  TPerson = class;

  TPersonArray = array of TPerson;

  IState = interface(IInterface)
    function Handle(): IState;
  end;

  TPersonState = class(TInterfacedObject, IState)
    private
      FPerson: TPerson;
    public
      property Person: TPerson read FPerson write FPerson;
      function Handle(): IState; virtual; abstract;
  end;

  TStateHealthy = class(TPersonState, IState)
    private
      FTicksNearSickPeople: TDictionary<TPerson, uint8>;
    public
      function Handle(): IState;
      property TicksNearSickPeople: TDictionary<TPerson, uint8> read FTicksNearSickPeople write FTicksNearSickPeople;
  end;

  TStateSickAsymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint16;
    public
      constructor Create(ATimeUntilResistant: uint16);
      function Handle(): IState;
      property TicksUntilResistand: uint16 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateSickSymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint16;
    public
      constructor Create(ATimeUntilResistant: uint16);
      function Handle(): IState;
      property TicksUntilResistand: uint16 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateResistant = class(TPersonState, IState)
    public
      function Handle(): IState;
  end;

  TMemento = class(TInterfacedObject)
    State: TClass;
    x: double;
    y: double;
  end;

  TPerson = class(TObject)
    private
      FPositionVector: TVector2D;
      FVelocityVector: TVectorVelocity;
      FState: IState;
    public
      constructor Create(Ax, Ay: double; AState: IState);
      property PositionVector: TVector2D read FPositionVector write FPositionVector;
      property VelocityVector: TVectorVelocity read FVelocityVector write FVelocityVector;
      property State: IState read FState write FState;
      function GetMemento(): TMemento;
      procedure Move();
  end;

  TPopulation = class(TObject)
    private
      FPopulationArray: TPersonArray;
      FSizeN: double;
      FSizeM: double;
      class var
        Population: TPopulation;
    public
      class function GetInstance(): TPopulation; static;
      procedure Update();
      procedure AddPerson(Ax, Ay: double; AState: IState);
      property PopulationArray: TPersonArray read FPopulationArray write FPopulationArray;
      property SizeN: double read FSizeN write FSizeN;
      property SizeM: double read FSizeM write FSizeM;
  end;

{ TPopulation }

procedure TPopulation.AddPerson(Ax, Ay: double; AState: IState);
begin
  SetLength(FPopulationArray, Length(PopulationArray)-1);
  FPopulationArray[High(FPopulationArray)]:= TPerson.Create(Ax, Ay, AState);
end;

class function TPopulation.GetInstance: TPopulation;
begin
  if Population = nil then
      Population:= TPopulation.Create;
  Result:= Population;
end;

procedure TPopulation.Update;
var
  i: uint32;
  NewState: IState;
begin
  for i:= 0 to High(PopulationArray) do
  begin
    NewState:= PopulationArray[i].State.Handle;
    if NewState <> nil then
    begin
      (PopulationArray[i].State as TPersonState).Free;
      PopulationArray[i].State:= NewState;
    end;
    PopulationArray[i].Move();
  end;
end;

{ TStateHealthy }

function TStateHealthy.Handle: IState;
var
  i: uint32;
  Difference: TVector2D;
begin
  Result:= nil;
  for i := 0 to High(TPopulation.GetInstance.PopulationArray) do
  begin
    Difference:= Person.PositionVector.diff(TPopulation.GetInstance.PopulationArray[i].PositionVector);
    if Difference.abs() <= 3 then
    begin
      if TicksNearSickPeople.ContainsKey(TPopulation.GetInstance.PopulationArray[i]) then
        TicksNearSickPeople.AddOrSetValue(TPopulation.GetInstance.PopulationArray[i], TicksNearSickPeople[TPopulation.GetInstance.PopulationArray[i]]+1)
      else
        TicksNearSickPeople.Add(TPopulation.GetInstance.PopulationArray[i], 0)
    end
    else
      if TicksNearSickPeople.ContainsKey(TPopulation.GetInstance.PopulationArray[i]) then
        TicksNearSickPeople.Remove(TPopulation.GetInstance.PopulationArray[i]);
  end;
  for i:= 0 to TicksNearSickPeople.Keys.Count-1 do
    if TicksNearSickPeople.Values.ToArray[i] >= 75 then
      if ((TicksNearSickPeople.Keys.ToArray[i].ClassType = TStateSickAsymptomatic) AND (Random(2) = 0)) OR
          (TicksNearSickPeople.Keys.ToArray[i].ClassType = TStateSickSymptomatic) then
            begin
              TicksNearSickPeople.Remove(TicksNearSickPeople.Keys.ToArray[i]);
              if Random(2) = 0 then
                Result:= TStateSickSymptomatic.Create(Random(251)+500)
              else
                Result:= TStateSickAsymptomatic.Create(Random(251)+500);
            end;
end;

{ TStateSickAsymptomatic }

constructor TStateSickAsymptomatic.Create(ATimeUntilResistant: uint16);
begin
  inherited Create;
  TicksUntilResistand:= ATimeUntilResistant;
end;

function TStateSickAsymptomatic.Handle: IState;
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

function TStateSickSymptomatic.Handle: IState;
begin
  TicksUntilResistand:= TicksUntilResistand-1;
  if TicksUntilResistand = 0 then
    Result:= TStateResistant.Create();
end;

{ TStateResistant }

function TStateResistant.Handle: IState;
begin
  //
end;

{ TPerson }

constructor TPerson.Create(Ax, Ay: double; AState: IState);
begin
  PositionVector:= TVector2D.Create(Ax, Ay);
  State:= AState;
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
  VelocityVector.SetAngle(Random*6.28319);
  VelocityVector.SetModule(Random*2.5);
  PositionVector.x:= PositionVector.x + VelocityVector.x; PositionVector.y:= PositionVector.y + VelocityVector.y;

end;

begin
  TPopulation.GetInstance.SizeN:= 100;
  TPopulation.GetInstance.SizeM:= 100;
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
  TPopulation.GetInstance.AddPerson(0, 0, TStateSickSymptomatic.Create(30000));
  TPopulation.GetInstance.AddPerson(0, 0, TStateHealthy.Create());
end.
