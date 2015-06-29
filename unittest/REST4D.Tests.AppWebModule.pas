unit REST4D.Tests.AppWebModule;

interface

uses
  System.SysUtils,
  System.Classes,
  REST4D,
  REST4D.Server,
  REST4D.WebModule;

type

  TAppWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  strict protected
    procedure ConfigureRESTEngine(const pRESTEngine: TRESTEngine); override;
    function GetRESTSecurity(): IRESTSecurity; override;
  public
    { Public declarations }
  end;

var
  AppWebModuleClass: TComponentClass = TAppWebModule;

implementation

uses
  REST4D.Tests.AppController;

{$R *.dfm}

{ TAppWebModule }

procedure TAppWebModule.ConfigureRESTEngine(const pRESTEngine: TRESTEngine);
begin
  inherited;
  pRESTEngine.AddController(TAppController);
end;

function TAppWebModule.GetRESTSecurity: IRESTSecurity;
begin
  Result := RESTServerDefault.Container.FindServerByName('Server1').Info.Security;
end;

end.
