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

uses
  MVCFramework.Middleware.Authentication;

{$R *.dfm}

procedure TRESTWebModule.AfterConstruction;
var
  vServer: IRESTServer;
begin
  inherited AfterConstruction;
  FRESTEngine := TRESTEngine.Create(Self);
  FRESTEngine.ServerName := EmptyStr;

  Initialize();

  if FRESTEngine.ServerName.IsEmpty then
    raise ERESTSeverException.Create('ServerName was not informed on RESTEngine!');

  vServer := RESTServer.Container.FindServerByName(FRESTEngine.ServerName);
  if (vServer <> nil) and (vServer.Info.Security <> nil) then
    FRESTEngine.AddMiddleware(TMVCBasicAuthenticationMiddleware.Create(vServer.Info.Security))
end;

procedure TRESTWebModule.BeforeDestruction;
begin
  FreeAndNil(FRESTEngine);
  inherited BeforeDestruction;
end;

end.
