unit Vectors;

interface

type
  TDoubleArray = array of double;

  IVector = interface(IInterface)
    function getComponents(): TDoubleArray;
    function abs(): double;
    function cdot(AVector: TObject): double;
  end;

  TVector2D = class(TInterfacedObject, IVector)
    private
      x: double;
      y: double;
    public
      constructor Create(Ax, Ay: double);
      function getComponents(): TDoubleArray;
      function abs(): double;
      function cdot(AVector: TObject): double;
  end;

  TVectorVelocity = class(TVector2D, IVector)
    public
      procedure SetAngle(AAngle: double);
      procedure SetModule(AModule: double);
  end;

implementation

uses
  Math;

{ TVector2D }

constructor TVector2D.Create(Ax, Ay: double);
begin
  inherited Create;
  x:= Ax;
  y:= Ay;
end;

function TVector2D.abs: double;
begin
  Result:= sqrt(x*x + y*y);
end;

function TVector2D.cdot(AVector: TObject): double;
begin
  Result:= Self.x*(AVector as TVector2D).x+Self.y*(AVector as TVector2D).y;
end;

function TVector2D.getComponents(): TDoubleArray;
begin
  setLength(Result, 2);
  Result[0]:= x; Result[1]:= y;
end;

{ TVectorVelocity }

procedure TVectorVelocity.SetAngle(AAngle: double);
begin
  x:= sqrt(Sqr(abs())/(sqr(tan(AAngle))+1));
  y:= tan(AAngle)*x;
end;

procedure TVectorVelocity.SetModule(AModule: double);
var
  Angle: double;
begin
  Angle:= ArcTan(y/x);
  x:= sqrt(Sqr(AModule)/(sqr(tan(Angle))+1));
  y:= tan(Angle)*x;
end;

end.
