unit Frm.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Collections;

type

  TFrmMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  REST4D, REST4D.Server,
  BasicDemo.AppWebModule;

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
var
  vServerInfo: IRESTServerInfo;
  vOnAuthentication: TRESTAuthenticationDelegate;
begin
  vServerInfo := TRESTServerInfoFactory.Build;
  vServerInfo.ServerName := 'ServerBasicDemo';
  vServerInfo.Port := 3000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := BasicDemoWebModuleClass;

  vOnAuthentication := procedure(const pUserName, pPassword: string;
      pUserRoles: TList<string>; var pIsValid: Boolean)
    begin
      pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
    end;

  vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);

  RESTServer.Container.CreateServer(vServerInfo);
  RESTServer.Container.StartServers;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  RESTServer.Container.StopServers;
end;

end.
