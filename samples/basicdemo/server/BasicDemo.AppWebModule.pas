unit BasicDemo.AppWebModule;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
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
