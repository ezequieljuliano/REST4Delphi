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

    procedure Initialize(const pRESTEngine: TRESTEngine); virtual; abstract;
    procedure SecurityLayer(out pRESTSecurity: IRESTSecurity); virtual; abstract;
  end;

implementation

uses
  MVCFramework.Middleware.Authentication;

{$R *.dfm}

procedure TRESTWebModule.AfterConstruction;
var
  vSecurity: IRESTSecurity;
begin
  inherited AfterConstruction;
  FRESTEngine := TRESTEngine.Create(Self);

  Initialize(FRESTEngine);
  SecurityLayer(vSecurity);

  if (vSecurity <> nil) then
    FRESTEngine.AddMiddleware(TMVCBasicAuthenticationMiddleware.Create(vSecurity))
end;

procedure TRESTWebModule.BeforeDestruction;
begin
  FreeAndNil(FRESTEngine);
  inherited BeforeDestruction;
end;

end.
