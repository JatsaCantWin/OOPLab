unit Vectors;

interface

type
  TDoubleArray = array of double;

  IVector = interface(IInterface)
    function getComponents(): TDoubleArray;
    function abs(): double;
    function cdot(AVector: TObject): double;
  end;

  TVector = class(TInterfacedObject, IVector)
    private
      Fx: double;
      Fy: double;
    public
      constructor Create(Ax, Ay: double);
      function getComponents(): TDoubleArray;
      function abs(): double;
      function cdot(AVector: TObject): double;
      function add(AVector: TVector): TVector;
      function diff(AVector: TVector): TVector;
      function getAngle(): double;
      property x: double read fx write fx;
      property y: double read fy write fy;
  end;

implementation

uses
  Math;

{ TVector }

constructor TVector.Create(Ax, Ay: double);
begin
  inherited Create;
  x:= Ax;
  y:= Ay;
end;

function TVector.add(AVector: TVector): TVector;
begin
  Result:= TVector.Create(x+AVector.x, y+AVector.y);
end;

function TVector.diff(AVector: TVector): TVector;
begin
  Result:= TVector.Create(x-AVector.x, y-AVector.y);
end;

function TVector.abs: double;
begin
  Result:= sqrt(x*x + y*y);
end;

function TVector.cdot(AVector: TObject): double;
begin
  Result:= Self.x*(AVector as TVector).x+Self.y*(AVector as TVector).y;
end;

function TVector.getComponents(): TDoubleArray;
begin
  setLength(Result, 2);
  Result[0]:= x; Result[1]:= y;
end;

function TVector.getAngle: double;
begin
  Result:= Tan(y/x);
end;

end.
