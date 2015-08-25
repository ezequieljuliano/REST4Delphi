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
    FRESTSecurity: IRESTSecurity;
  strict protected
    procedure ConfigureRESTEngine(const pRESTEngine: TRESTEngine); virtual;
    function GetRESTSecurity(): IRESTSecurity; virtual;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

implementation

{$R *.dfm}

procedure TRESTWebModule.AfterConstruction;
begin
  inherited AfterConstruction;
  FRESTEngine := TRESTEngine.Create(Self);
  ConfigureRESTEngine(FRESTEngine);

  FRESTSecurity := GetRESTSecurity();
  if (FRESTSecurity <> nil) then
    FRESTEngine.AddMiddleware(TRESTBasicAuthenticationMiddleware.Create(FRESTSecurity))
end;

procedure TRESTWebModule.BeforeDestruction;
begin
  FreeAndNil(FRESTEngine);
  inherited BeforeDestruction;
end;

procedure TRESTWebModule.ConfigureRESTEngine(const pRESTEngine: TRESTEngine);
begin
  // With this method you can set the settings of your RESTEngine
end;

function TRESTWebModule.GetRESTSecurity: IRESTSecurity;
begin
  // With this method you return your security layer, the default is nil
  Result := nil;
end;

end.
