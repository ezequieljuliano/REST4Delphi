unit CustomDMVC.UnitTest;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  CustomDMVC,
  MVCFramework.RESTClient;

type

  TTestCustomDMVC = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestUserAndPass();
    procedure TestApiKey();
  end;

implementation

uses
  App.WebModule;

{ TTestCustomDMVC }

procedure TTestCustomDMVC.SetUp;
var
  vServerInfo: ICustomMVCServerInfo;
begin
  inherited;
  vServerInfo := TCustomMVC.NewServerInfo;
  vServerInfo.ServerName := 'Server1';
  vServerInfo.Port := 3000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := AppWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  TCustomMVC.ServerManager.CreateServer(vServerInfo);
  TCustomMVC.ServerManager.StartServers();
end;

procedure TTestCustomDMVC.TearDown;
begin
  inherited;

end;

procedure TTestCustomDMVC.TestApiKey;
var
  vRESTClient: TRESTClient;
  vResponse: IRESTResponse;
begin
  vRESTClient := TRESTClient.Create('localhost', 3000);
  try
    vRESTClient.RequestHeaders.Add('ApiKey=8d75ebf9dd230e87d35aa305387c6b074ce475b9');
    vResponse := vRESTClient.doGET('/hello', []);

    CheckTrue((vResponse.BodyAsString = '"Hello World!"'));
  finally
    FreeAndNil(vRESTClient);
  end;
end;

procedure TTestCustomDMVC.TestUserAndPass;
var
  vRESTClient: TRESTClient;
  vResponse: IRESTResponse;
begin
  vRESTClient := TRESTClient.Create('localhost', 3000);
  try
    vRESTClient.RequestHeaders.Add('Authorization=Basic ZXplcXVpZWw6MTIz');
    vResponse := vRESTClient.doGET('/hello', []);

    CheckTrue((vResponse.BodyAsString = '"Hello World!"'));
  finally
    FreeAndNil(vRESTClient);
  end;
end;

initialization

RegisterTest(TTestCustomDMVC.Suite);

end.
