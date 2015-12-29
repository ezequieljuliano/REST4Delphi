unit REST4D.Tests.UnitTest;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  REST4D,
  REST4D.Server,
  REST4D.Client,
  REST4D.Adapter,
  REST4D.Tests.AppWebModule,
  REST4D.Tests.AppController,
  REST4D.Tests.TempWebModule,
  System.Generics.Collections,
  REST4D.Mapping;

type

  IAppResource = interface(IInvokable)
    ['{D139CD79-CFE5-49E3-8CFB-27686621911B}']

    [RESTResource(THTTPMethod.httpGET, '/hello')]
    function HelloWorld(): string;

    [RESTResource(THTTPMethod.httpGET, '/user')]
    function GetUser(): TUser;

    [RESTResource(THTTPMethod.httpPOST, '/user/save')]
    procedure PostUser([Body] pBody: TUser);

    [RESTResource(THTTPMethod.httpGET, '/users')]
    [MapperListOf(TUser)]
    function GetUsers(): TObjectList<TUser>;

    [RESTResource(THTTPMethod.httpPOST, '/users/save')]
    [MapperListOf(TUser)]
    procedure PostUsers([Body] pBody: TObjectList<TUser>);

  end;

  TTestREST4D = class(TTestCase)
  private
    FRESTfulClient: TRESTfulClient;
    FRESTAdapter: TRESTAdapter<IAppResource>;
    FAppResource: IAppResource;
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

{ TTestREST4D }

procedure TTestREST4D.SetUp;
var
  vServerInfo: IRESTServerInfo;
  vOnAuthentication: TRESTAuthenticationDelegate;
begin
  inherited;
  vServerInfo := TRESTServerInfoFactory.Build;
  vServerInfo.ServerName := 'Server1';
  vServerInfo.Port := 3000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := AppWebModuleClass;

  vOnAuthentication := procedure(const pUserName, pPassword: string;
      pUserRoles: TList<string>; var pIsValid: Boolean)
    begin
      pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
    end;

  vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);

  RESTServerDefault.Container.CreateServer(vServerInfo);
  RESTServerDefault.Container.StartServers;

  FRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  FRESTAdapter := TRESTAdapter<IAppResource>.Create;
  FRESTAdapter.Build(FRESTfulClient);
  FAppResource := FRESTAdapter.ResourcesService;
end;

procedure TTestREST4D.TearDown;
begin
  inherited;
  RESTServerDefault.Container.StopServers;
  FreeAndNil(FRESTfulClient);
end;

procedure TTestREST4D.TestCreateServer;
var
  vServerInfo: IRESTServerInfo;
  vOnAuthentication: TRESTAuthenticationDelegate;
begin
  vServerInfo := TRESTServerInfoFactory.Build;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;

  vOnAuthentication := procedure(const pUserName, pPassword: string;
      pUserRoles: TList<string>; var pIsValid: Boolean)
    begin
      pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
    end;

  vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);

  RESTServerDefault.Container.CreateServer(vServerInfo);

  CheckTrue(RESTServerDefault.Container.FindServerByName('ServerTemp') <> nil);
end;

procedure TTestREST4D.TestDestroyServer;
var
  vServerInfo: IRESTServerInfo;
  vOnAuthentication: TRESTAuthenticationDelegate;
begin
  vServerInfo := TRESTServerInfoFactory.Build;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;

  vOnAuthentication := procedure(const pUserName, pPassword: string;
      pUserRoles: TList<string>; var pIsValid: Boolean)
    begin
      pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
    end;

  vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);

  RESTServerDefault.Container.CreateServer(vServerInfo);
  RESTServerDefault.Container.DestroyServer('ServerTemp');

  CheckTrue(RESTServerDefault.Container.FindServerByName('ServerTemp') = nil);
end;

procedure TTestREST4D.TestFindServerByName;
var
  vServerInfo: IRESTServerInfo;
  vOnAuthentication: TRESTAuthenticationDelegate;
begin
  vServerInfo := TRESTServerInfoFactory.Build;
  vServerInfo.ServerName := 'ServerTemp';
  vServerInfo.Port := 4000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := TempWebModuleClass;

  vOnAuthentication := procedure(const pUserName, pPassword: string;
      pUserRoles: TList<string>; var pIsValid: Boolean)
    begin
      pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
    end;

  vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);

  RESTServerDefault.Container.CreateServer(vServerInfo);

  CheckTrue(RESTServerDefault.Container.FindServerByName('ServerTemp') <> nil);
end;

procedure TTestREST4D.TestGetUser;
var
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  FRESTfulClient.Resource('/user').Params([]);
  FRESTfulClient.Authentication('ezequiel', '123');

  // String
  vResp := FRESTfulClient.GET;
  CheckTrue(
    ('{"Cod":1,"Name":"Ezequiel","Pass":"123"}' = vResp.AsString) and
    (vResp.StatusCode = 200)
    );

  // Object
  vUser := FRESTfulClient.GET.AsObject<TUser>();
  try
    CheckTrue((vUser <> nil) and (vUser.Cod > 0));
  finally
    FreeAndNil(vUser);
  end;

  // Adapter
  vUser := FAppResource.GetUser;
  try
    CheckTrue((vUser <> nil) and (vUser.Cod > 0));
  finally
    FreeAndNil(vUser);
  end;
end;

procedure TTestREST4D.TestGetUsers;
var
  vUsers: TObjectList<TUser>;
begin
  FRESTfulClient.Resource('/users').Params([]);
  FRESTfulClient.Authentication('ezequiel', '123');

  // String
  CheckEqualsString('[{"Cod":0,"Name":"Ezequiel 0","Pass":"0"},{"Cod":1,"Name":"Ezequiel 1","Pass":"1"},' +
    '{"Cod":2,"Name":"Ezequiel 2","Pass":"2"},{"Cod":3,"Name":"Ezequiel 3","Pass":"3"},{"Cod":4,"Name":"Ezequiel 4","Pass":"4"},' +
    '{"Cod":5,"Name":"Ezequiel 5","Pass":"5"},{"Cod":6,"Name":"Ezequiel 6","Pass":"6"},{"Cod":7,"Name":"Ezequiel 7","Pass":"7"},' +
    '{"Cod":8,"Name":"Ezequiel 8","Pass":"8"},{"Cod":9,"Name":"Ezequiel 9","Pass":"9"},{"Cod":10,"Name":"Ezequiel 10","Pass":"10"}]',
    FRESTfulClient.GET.AsString);

  // Objects
  vUsers := FRESTfulClient.GET.AsObjectList<TUser>;
  try
    vUsers.OwnsObjects := True;
    CheckTrue(vUsers.Count > 0);
  finally
    FreeAndNil(vUsers);
  end;

  // Adapter
  vUsers := FAppResource.GetUsers;
  try
    vUsers.OwnsObjects := True;
    CheckTrue(vUsers.Count > 0);
  finally
    FreeAndNil(vUsers);
  end;
end;

procedure TTestREST4D.TestHelloWorld;
begin
  FRESTfulClient.Resource('/hello').Params([]);
  FRESTfulClient.Authentication('ezequiel', '123');

  // String
  CheckEqualsString('"Hello World called with GET"', FRESTfulClient.GET.AsString);

  // Adapter
  CheckEqualsString('"Hello World called with GET"', FAppResource.HelloWorld);
end;

procedure TTestREST4D.TestPostUser;
var
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  FRESTfulClient.Resource('/user/save').Params([]);
  FRESTfulClient.Authentication('ezequiel', '123');

  vUser := TUser.Create;
  vUser.Cod := 1;
  vUser.Name := 'Ezequiel';
  vUser.Pass := '123';
  vResp := FRESTfulClient.POST<TUser>(vUser);
  CheckTrue(('"Sucess!"' = vResp.AsString) and (vResp.StatusCode = 200));

  // Adapter
  vUser := TUser.Create;
  vUser.Cod := 1;
  vUser.Name := 'Ezequiel';
  vUser.Pass := '123';
  FAppResource.PostUser(vUser);
end;

procedure TTestREST4D.TestPostUsers;
var
  vUsers: TObjectList<TUser>;
  vResp: TRESTfulResponse;
  I: Integer;
  vUser: TUser;
begin
  FRESTfulClient.Resource('/users/save').Params([]);
  FRESTfulClient.Authentication('ezequiel', '123');
  FRESTfulClient.ContentType('application/json; charset=utf-8');

  vUsers := TObjectList<TUser>.Create(True);
  for I := 0 to 10 do
  begin
    vUser := TUser.Create;
    vUser.Cod := I;
    vUser.Name := 'Ezequiel ˆ¸·‡Á„ı∫s ' + IntToStr(I);
    vUser.Pass := IntToStr(I);
    vUsers.Add(vUser);
  end;
  vResp := FRESTfulClient.POST<TUser>(vUsers);
  CheckTrue(('"Sucess!"' = vResp.AsString) and (vResp.StatusCode = 200));

  // Adapter
  vUsers := TObjectList<TUser>.Create(True);
  for I := 0 to 10 do
  begin
    vUser := TUser.Create;
    vUser.Cod := I;
    vUser.Name := 'Ezequiel ˆ¸·‡Á„ı∫s ' + IntToStr(I);
    vUser.Pass := IntToStr(I);
    vUsers.Add(vUser);
  end;
  FAppResource.PostUsers(vUsers);
end;

initialization

RegisterTest(TTestREST4D.Suite);

end.
