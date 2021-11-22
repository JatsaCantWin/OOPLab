program Lab4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Vectors in 'Vectors.pas';

type
  TPerson = class;

  IState = interface(IInterface)
    procedure Handle();
  end;

  TPersonState = class(TInterfacedObject, IState)
    private
      FPerson: TPerson;
    public
      property Person: TPerson read FPerson write FPerson;
      procedure Handle(); virtual; abstract;
  end;

  TStateHealthy = class(TPersonState, IState)
    private
      FTicksNearSickPerson: uint8;
    public
      procedure Handle();
      property TicksNearSickPerson: uint8 read FTicksNearSickPerson write FTicksNearSickPerson;
  end;

  TStateSickAsymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint8;
    public
      procedure Handle();
      property TicksUntilResistand: uint8 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateSickSymptomatic = class(TPersonState, IState)
    private
      FTicksUntilResistant: uint8;
    public
      procedure Handle();
      property TicksUntilResistand: uint8 read FTicksUntilResistant write FTicksUntilResistant;
  end;

  TStateResistant = class(TPersonState, IState)
    public
      procedure Handle();
  end;

  TPerson = class(TObject)
    private
      FPositionVector: TVector2D;
      FVelocityVector: TVectorVelocity;
      FState: IState;
    public
      property PositionVector: TVector2D read FPositionVector write FPositionVector;
      property VelocityVector: TVectorVelocity read FVelocityVector write FVelocityVector;
      property State: IState read FState write FState;
  end;

  TPersonArray = array of TPerson;

  TPopulation = class(TObject)
    private
      FPopulationArray: TPersonArray;
      class var
        Population: TPopulation;
    public
      procedure GetInstance(); static;
      procedure Update();
      property PopulationArray: TPersonArray read FPopulationArray write FPopulationArray;
  end;

{ TPopulation }

procedure TPopulation.GetInstance;
begin
  //
end;

procedure TPopulation.Update;
var
  i: uint32;
begin
  for i:= 0 to High(PopulationArray) do
    PopulationArray[i].State.Handle;
end;

{ TStateHealthy }

procedure TStateHealthy.Handle;
var
  i: uint32;
begin
  //for i := 0 to High() do

end;

begin

end.
