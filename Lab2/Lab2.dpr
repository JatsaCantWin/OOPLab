program Lab2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Math;

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

  T2DPolarInheritance = class(TVector2D)
    public
      function getAngle(): double;
  end;

  IPolar2D = interface(IInterface)
    function abs(): double;
    function getAngle(): double;
  end;

  TPolar2DAdapter = class(TInterfacedObject, IVector, IPolar2D)
    private
      srcVector: TVector2D;
    public
      procedure setSrcVector(ASrcVector: TVector2D);
      function getComponents(): TDoubleArray;
      function abs(): double;
      function cdot(AVector: TObject): double;
      function getAngle(): double;
  end;

  TVector3DInheritance = class(TVector2D)
    private
      z: double;
    public
      constructor Create(Ax, Ay, Az: double);
      function getComponents(): TDoubleArray;
      function abs(): double;
      function cdot(AVector: TObject): double;
      function cross(AVector: TVector2D): TVector3DInheritance;
      function getSrcV(): TVector2D;
  end;

  TVector3DDecorator = class(TInterfacedObject, IVector)
    private
      srcVector: IVector;
      z: double;
    public
      constructor Create(AsrcVector: IVector; Az: double);
      function getComponents(): TDoubleArray;
      function abs(): double;
      function cdot(AVector: TObject): double;
      function cross(AVector: TVector2D): TVector3DDecorator;
      function getSrcV(): IVector;
  end;

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

{ T2DPolarInheritance }

function T2DPolarInheritance.getAngle: double;
begin
  Result:= Tan(y/x);
end;

{ TPolar2DAdapter }

procedure TPolar2DAdapter.setSrcVector(ASrcVector: TVector2D);
begin
  srcVector:= ASrcVector;
end;

function TPolar2DAdapter.abs: double;
begin
  Result:= srcVector.abs();
end;

function TPolar2DAdapter.cdot(AVector: TObject): double;
begin
  Result:= srcVector.cdot(AVector);
end;

function TPolar2DAdapter.getAngle: double;
begin
  Result:= ArcTan(srcVector.y/srcVector.x);
end;

function TPolar2DAdapter.getComponents: TDoubleArray;
begin
  Result:= srcVector.getComponents();
end;

{ TVector3DInheritance }

constructor TVector3DInheritance.Create(Ax, Ay, Az: double);
begin
  inherited Create(Ax, Ay);
  z:= Az;
end;

function TVector3DInheritance.abs: double;
begin
  Result:= sqrt(x*x + y*y + z*z);
end;

function TVector3DInheritance.cdot(AVector: TObject): double;
begin
  Result:= Self.x*(AVector as TVector2D).x+Self.y*(AVector as TVector2D).y;
  if AVector.ClassType = TVector3DInheritance then
    Result:= Result + Self.z + (AVector as TVector3DInheritance).z;
end;

function TVector3DInheritance.getComponents: TDoubleArray;
begin
  setLength(Result, 3);
  Result[0]:= x; Result[1]:= y; Result[2]:= z;
end;

function TVector3DInheritance.cross(AVector: TVector2D): TVector3DInheritance;
var
  z2: double;
begin
  if AVector.ClassType = TVector3DInheritance then
    z2:= (AVector as TVector3DInheritance).z
  else
    z2:= 0;
  Result:= TVector3DInheritance.Create(Self.y*z2-Self.z*(AVector as TVector3DInheritance).y, Self.x*z2-Self.z*(AVector as TVector3DInheritance).x, Self.x*(AVector as TVector3DInheritance).y-Self.y*(AVector as TVector3DInheritance).x)
end;

function TVector3DInheritance.getSrcV: TVector2D;
begin
  Result:= TVector2D.Create(x, y);
end;

{ TVector3DDecorator }

constructor TVector3DDecorator.Create(AsrcVector: IVector; Az: double);
begin
  inherited Create;
  srcVector:= AsrcVector;
  z:= Az;
end;

function TVector3DDecorator.abs: double;
begin
  Result:= srcVector.abs()
end;

function TVector3DDecorator.cdot(AVector: TObject): double;
begin
  Result:= srcVector.cdot(AVector);
end;

function TVector3DDecorator.getComponents: TDoubleArray;
begin
  Result:= srcVector.getComponents();
  SetLength(Result, 3);
  Result[2]:= z;
end;

function TVector3DDecorator.cross(AVector: TVector2D): TVector3DDecorator;
var
  z2: double;
  ResultSrcVector: TVector2D;
begin
  if AVector.ClassType = TVector3DInheritance then
    z2:= (AVector as TVector3DInheritance).z
  else
    z2:= 0;

  ResultSrcVector:= TVector2D.Create((srcVector as TVector2D).y*z2-Self.z*(AVector as TVector2D).y, (srcVector as TVector2D).x*z2-Self.z*(AVector as TVector2D).x);
  Result:= TVector3DDecorator.Create(ResultSrcVector, (srcVector as TVector2D).x*(AVector as TVector2D).y-(srcVector as TVector2D).y*(AVector as TVector2D).x)
end;

function TVector3DDecorator.getSrcV: IVector;
begin
  Result:= srcVector;
end;

var
  A, B, C: TVector2D;
  A3D, B3D, C3D: TVector3DDecorator;
  AxC, AxB, BxC: TVector3DDecorator;
  Polar2DAdapter: TPolar2DAdapter;
  x: integer;

begin
  A:= TVector2D.Create(10, 5); B:= TVector2D.Create(-2, 4.5); C:= TVector2D.Create(2, 1);
  A3D:= TVector3DDecorator.Create(A, 0); B3D:= TVector3DDecorator.Create(B, 0); C3D:= TVector3DDecorator.Create(C, 0);
  Polar2DAdapter:= TPolar2DAdapter.Create;
  Polar2DAdapter.setSrcVector(A);
  writeLn('Wektor A: [' + FloatToStr(A.getComponents[0]) + ' ' + FloatToStr(A.getComponents[1]) + ' 0] ' + FloatToStr(Polar2DAdapter.getAngle) + ' rad');
  Polar2DAdapter.setSrcVector(B);
  writeLn('Wektor B: [' + FloatToStr(B.getComponents[0]) + ' ' + FloatToStr(B.getComponents[1]) + ' 0] ' + FloatToStr(Polar2DAdapter.getAngle) + ' rad');
  Polar2DAdapter.setSrcVector(C);
  writeLn('Wektor C: [' + FloatToStr(C.getComponents[0]) + ' ' + FloatToStr(C.getComponents[1]) + ' 0] ' + FloatToStr(Polar2DAdapter.getAngle) + ' rad');
  AxC:= A3D.cross(C); AxB:= A3D.cross(B); BxC:= B3D.cross(C);
  writeLn('A * C: ' + FloatToStr(A.cdot(C)) + ' A x C: [' + FloatToStr(AxC.srcVector.getComponents[0]) + ' ' + FloatToStr(AxC.srcVector.getComponents[1]) + ' ' + FloatToStr(AxC.z) + ']');
  writeLn('A * B: ' + FloatToStr(A.cdot(B)) + ' A x B: [' + FloatToStr(AxB.srcVector.getComponents[0]) + ' ' + FloatToStr(AxB.srcVector.getComponents[1]) + ' ' + FloatToStr(AxB.z) + ']');
  writeLn('B * C: ' + FloatToStr(B.cdot(C)) + ' B x C: [' + FloatToStr(BxC.srcVector.getComponents[0]) + ' ' + FloatToStr(BxC.srcVector.getComponents[1]) + ' ' + FloatToStr(BxC.z) + ']');
end.
