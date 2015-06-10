unit BasicDemo.AppWebModule;

interface

uses
  System.SysUtils,
  System.Classes,
  REST4D.WebModule;

type

  TBasicDemoWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  BasicDemoWebModuleClass: TComponentClass = TBasicDemoWebModule;

implementation

uses
  User.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TBasicDemoWebModule.Initialize;
begin
  inherited;
  RESTEngine.AddController(TUserController);
  RESTEngine.ServerName := 'ServerBasicDemo';
end;

end.
