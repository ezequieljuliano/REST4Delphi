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
  public
    procedure Initialize(const pRESTEngine: TRESTEngine); override;
    procedure SecurityLayer(out pRESTSecurity: IRESTSecurity); override;
  end;

var
  AppWebModuleClass: TComponentClass = TAppWebModule;

implementation

uses
  REST4D.Tests.AppController;

{$R *.dfm}

{ TAppWebModule }

procedure TAppWebModule.Initialize(const pRESTEngine: TRESTEngine);
begin
  inherited;
  pRESTEngine.AddController(TAppController);
end;

procedure TAppWebModule.SecurityLayer(out pRESTSecurity: IRESTSecurity);
begin
  inherited;
  pRESTSecurity := RESTServerDefault.Container.FindServerByName('Server1').Info.Security;
end;

end.
