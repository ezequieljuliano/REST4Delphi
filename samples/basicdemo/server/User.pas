unit User;

interface

type

  TUser = class
  strict private
    FCod: Integer;
    FName: string;
    FPass: string;
  public
    property Cod: Integer read FCod write FCod;
    property Name: string read FName write FName;
    property Pass: string read FPass write FPass;
  end;

implementation

end.
