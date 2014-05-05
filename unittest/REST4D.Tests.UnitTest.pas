unit REST4D.Tests.UnitTest;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  REST4D,
  REST4D.Server,
  REST4D.Client,
  REST4D.Tests.AppWebModule,
  System.Generics.Collections;

type

  TTestREST4D = class(TTestCase)
  private
    FServerContainer: IRESTServerContainer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreateServer();
    procedure TestDestroyServer();
    procedure TestFindServerByName();

    procedure TestHelloWorld();
    procedure TestGetUser();
    procedure TestPostUser();
    procedure TestPostUsers();
    procedure TestGetUsers();
  end;

implementation

uses
  REST4D.Tests.AppController,
  REST4D.Tests.TempWebModule;

{ TTestREST4D }

procedure TTestREST4D.SetUp;
var
  vServerInfo: IRESTServerInfo;
begin
  inherited;
  vServerInfo := TRESTServerInfoFactory.GetInstance;
  vServerInfo.ServerName := 'Server1';
  vServerInfo.Port := 3000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := AppWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  FServerContainer := TRESTServerContainerFactory.GetSingleton;
  FServerContainer.CreateServer(vServerInfo);
  FServerContainer.StartServers;
end;

procedure TTestREST4D.TearDown;
begin
  inherited;
  FServerContainer.StopServers;
end;

procedure TTestREST4D.TestCreateServer;
var
  vServerContainer: IRESTServerContainer;
  vServerInfo: IRESTServerInfo;
begin
  vServerInfo := TRESTServerInfoFactory.GetInstance;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  vServerContainer := TRESTServerContainerFactory.GetSingleton;
  vServerContainer.CreateServer(vServerInfo);

  CheckTrue(vServerContainer.FindServerByName('ServerTemp') <> nil);
end;

procedure TTestREST4D.TestDestroyServer;
var
  vServerContainer: IRESTServerContainer;
  vServerInfo: IRESTServerInfo;
begin
  vServerInfo := TRESTServerInfoFactory.GetInstance;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  vServerContainer := TRESTServerContainerFactory.GetSingleton;
  vServerContainer.CreateServer(vServerInfo);
  vServerContainer.DestroyServer('ServerTemp');

  CheckTrue(vServerContainer.FindServerByName('ServerTemp') = nil);
end;

procedure TTestREST4D.TestFindServerByName;
var
  vServerContainer: IRESTServerContainer;
  vServerInfo: IRESTServerInfo;
begin
  vServerInfo := TRESTServerInfoFactory.GetInstance;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  vServerContainer := TRESTServerContainerFactory.GetSingleton;
  vServerContainer.CreateServer(vServerInfo);

  CheckTrue(vServerContainer.FindServerByName('ServerTemp') <> nil);
end;

procedure TTestREST4D.TestGetUser;
var
  vRestCli: TRESTfulClient;
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/user').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vResp := vRestCli.GET;

    CheckTrue(
      ('{"Cod":1,"Name":"Ezequiel","Pass":"123"}' = vResp.AsString) and
      (vResp.StatusCode = 200)
      );
  finally
    FreeAndNil(vRestCli);
  end;

  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/user').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUser := vRestCli.GET.AsObject<TUser>();

    CheckTrue((vUser <> nil) and (vUser.Cod > 0));

    FreeAndNil(vUser);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TTestREST4D.TestGetUsers;
var
  vRestCli: TRESTfulClient;
  vUsers: TObjectList<TUser>;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/users').Params([]);
    vRestCli.Authorization('ezequiel', '123');
    CheckEqualsString('[{"Cod":0,"Name":"Ezequiel 0","Pass":"0"},{"Cod":1,"Name":"Ezequiel 1","Pass":"1"},' +
      '{"Cod":2,"Name":"Ezequiel 2","Pass":"2"},{"Cod":3,"Name":"Ezequiel 3","Pass":"3"},{"Cod":4,"Name":"Ezequiel 4","Pass":"4"},'+
      '{"Cod":5,"Name":"Ezequiel 5","Pass":"5"},{"Cod":6,"Name":"Ezequiel 6","Pass":"6"},{"Cod":7,"Name":"Ezequiel 7","Pass":"7"},'+
      '{"Cod":8,"Name":"Ezequiel 8","Pass":"8"},{"Cod":9,"Name":"Ezequiel 9","Pass":"9"},{"Cod":10,"Name":"Ezequiel 10","Pass":"10"}]',
      vRestCli.GET.AsString);
  finally
    FreeAndNil(vRestCli);
  end;

  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/users').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUsers := vRestCli.GET.AsObjectList<TUser>;
    vUsers.OwnsObjects := True;

    CheckTrue(vUsers.Count > 0);

    FreeAndNil(vUsers);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TTestREST4D.TestHelloWorld;
var
  vRESTCli: TRESTfulClient;
begin
  vRESTCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTCli.Resource('/hello').Params([]);
    vRESTCli.Authorization('ezequiel', '123');

    CheckEqualsString('"Hello World called with GET"', vRESTCli.GET.AsString);
  finally
    FreeAndNil(vRESTCli);
  end;
end;

procedure TTestREST4D.TestPostUser;
var
  vRestCli: TRESTfulClient;
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/user/save').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUser := TUser.Create;
    vUser.Cod := 1;
    vUser.Name := 'Ezequiel';
    vUser.Pass := '123';

    vResp := vRestCli.POST<TUser>(vUser);

    CheckTrue(
      ('"Sucess!"' = vResp.AsString) and (vResp.StatusCode = 200)
      );
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TTestREST4D.TestPostUsers;
var
  vRestCli: TRESTfulClient;
  vUsers: TObjectList<TUser>;
  vResp: TRESTfulResponse;
  I: Integer;
  vUser: TUser;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/users/save').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUsers := TObjectList<TUser>.Create(True);

    for I := 0 to 10 do
    begin
      vUser := TUser.Create;
      vUser.Cod := I;
      vUser.Name := 'Ezequiel ˆ¸·‡Á„ı∫s ' + IntToStr(I);
      vUser.Pass := IntToStr(I);

      vUsers.Add(vUser);
    end;

    vResp := vRestCli.POST<TUser>(vUsers);

    CheckTrue(
      ('"Sucess!"' = vResp.AsString) and (vResp.StatusCode = 200)
      );

  finally
    FreeAndNil(vRestCli);
  end;
end;

initialization

RegisterTest(TTestREST4D.Suite);

end.
