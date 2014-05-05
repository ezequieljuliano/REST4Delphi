unit REST4D.WebModule;

interface

uses
  REST4D,
  REST4D.Server,
  System.SysUtils,
  System.Classes,
  Web.HTTPApp;

type

  TRESTWebModule = class(TWebModule)
  strict private
    FRESTEngine: TRESTEngine;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Initialize(); virtual; abstract;

    property RESTEngine: TRESTEngine read FRESTEngine;
  end;

implementation

{$R *.dfm}

procedure TRESTWebModule.AfterConstruction;
begin
  inherited AfterConstruction;
  FRESTEngine := TRESTEngine.Create(Self);
  FRESTEngine.ServerName := EmptyStr;
  Initialize();
end;

procedure TRESTWebModule.BeforeDestruction;
begin
  FreeAndNil(FRESTEngine);
  inherited BeforeDestruction;
end;

end.
