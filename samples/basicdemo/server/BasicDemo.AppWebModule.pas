unit BasicDemo.AppWebModule;

interface

uses
  System.SysUtils,
  System.Classes,
  REST4D,
  REST4D.Server,
  REST4D.WebModule;

type

  TBasicDemoWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize(const pRESTEngine: TRESTEngine); override;
    procedure SecurityLayer(out pRESTSecurity: IRESTSecurity); override;
  end;

var
  BasicDemoWebModuleClass: TComponentClass = TBasicDemoWebModule;

implementation

uses
  User.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TBasicDemoWebModule.Initialize(const pRESTEngine: TRESTEngine);
begin
  inherited;
  pRESTEngine.AddController(TUserController);
end;

procedure TBasicDemoWebModule.SecurityLayer(out pRESTSecurity: IRESTSecurity);
begin
  inherited;
  pRESTSecurity := RESTServerDefault.Container.FindServerByName('ServerBasicDemo').Info.Security;
end;

end.
