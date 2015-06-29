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
  strict protected
    procedure ConfigureRESTEngine(const pRESTEngine: TRESTEngine); override;
    function GetRESTSecurity(): IRESTSecurity; override;
  public
    { Public declarations }
  end;

var
  BasicDemoWebModuleClass: TComponentClass = TBasicDemoWebModule;

implementation

uses
  User.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TBasicDemoWebModule.ConfigureRESTEngine(const pRESTEngine: TRESTEngine);
begin
  inherited;
  pRESTEngine.AddController(TUserController);
end;

function TBasicDemoWebModule.GetRESTSecurity: IRESTSecurity;
begin
  Result := RESTServerDefault.Container.FindServerByName('ServerBasicDemo').Info.Security;
end;

end.
