program Lab6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections;

type
  INameFlyweight = interface(IInterface)
    function GetName: String;
  end;

  TNameFlyweight = class(TInterfacedObject, INameFlyweight)
    private
      FName: String;
    public
      constructor Create(AName: String);
      function GetName: String;
  end;

  TNameFactory = class(TObject)
    private
      class var FNames: TList<INameFlyweight>;
    public
      class function GetName(AName: String): INameFlyweight;
  end;

  TPerson = class (TObject)
    private
      FName: INameFlyweight;
      FSurname: String;
      FCoordinateX: double;
      FCoordinateY: double;
      function GetName: String;
      procedure SetName(const Value: String);
    public
      property Name: String read GetName write SetName;
      property Surname: String read FSurname write FSurname;
      property CoordinateX: double read FCoordinateX write FCoordinateX;
      property CoordinateY: double read FCoordinateY write FCoordinateY;
  end;

{ TNameFlyweight }

constructor TNameFlyweight.Create(AName: String);
begin
  FName:= AName;
end;

function TNameFlyweight.GetName: String;
begin
  Result:= FName;
end;

{ TNameFactory }

class function TNameFactory.GetName(AName: String): INameFlyweight;
var
  CurrentFlyweight: INameFlyweight;
begin
  for CurrentFlyweight in FNames do
    if AName = CurrentFlyweight.GetName then
    begin
      Result:= CurrentFlyweight;
      Exit;
    end;
  FNames.Add(TNameFlyweight(AName));
  Result:= FNames.Last;
end;

{ TPerson }

function TPerson.GetName: String;
begin
  Result:= FName.GetName;
end;

procedure TPerson.SetName(const Value: String);
begin
  FName:= TNameFactory.GetName(Value);
end;

begin
  
end.
