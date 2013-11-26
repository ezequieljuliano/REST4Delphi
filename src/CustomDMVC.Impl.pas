(*
  Copyright 2013 Ezequiel Juliano Müller - ezequieljuliano@gmail.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

unit CustomDMVC.Impl;

interface

uses
  System.SysUtils,
  System.Classes,
  IdHTTPWebBrokerBridge,
  System.Generics.Collections,
  CustomDMVC,
  Spring,
  Spring.Services,
  CustomDMVC.Codification;

type

  TCustomMVCUserAuthenticate = class(TInterfacedObject, ICustomMVCUserAuthenticate)
  strict private
    FUserName: string;
    FPassword: string;
    FApiKey: string;
    procedure GenerateApiKey();
  public
    procedure AfterConstruction; override;

    function GetUserName(): string;
    procedure SetUserName(const pValue: string);

    function GetPassword(): string;
    procedure SetPassword(const pValue: string);

    function GetApiKey(): string;

    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
    property ApiKey: string read GetApiKey;
  end;

  TCustomMVCAuthentication = class(TInterfacedObject, ICustomMVCAuthentication)
  strict private
    FUsers: TDictionary<string, ICustomMVCUserAuthenticate>;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure AddUser(const pUserName, pPassword: string);

    procedure RemoveUser(const pUserName, pPassword: string); overload;
    procedure RemoveUser(const pApiKey: string); overload;

    function CountUsers(): Integer;

    function UserIsValid(const pUserName, pPassword: string): Boolean; overload;
    function UserIsValid(const pApiKey: string): Boolean; overload;
  end;

  TCustomMVCServerInfo = class(TInterfacedObject, ICustomMVCServerInfo)
  strict private
    FServerName: string;
    FPort: Integer;
    FMaxConnections: Integer;
    FWebModuleClass: TComponentClass;
    [Inject]
    FAuthentication: ICustomMVCAuthentication;
  public
    procedure AfterConstruction; override;

    function GetServerName(): string;
    procedure SetServerName(const pValue: string);

    function GetPort(): Integer;
    procedure SetPort(const pValue: Integer);

    function GetMaxConnections(): Integer;
    procedure SetMaxConnections(const pValue: Integer);

    function GetWebModuleClass(): TComponentClass;
    procedure SetWebModuleClass(const pValue: TComponentClass);

    function GetAuthentication(): ICustomMVCAuthentication;

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Authentication: ICustomMVCAuthentication read GetAuthentication;
  end;

  TCustomMVCServer = class(TInterfacedObject, ICustomMVCServer)
  strict private
    FServer: TIdHTTPWebBrokerBridge;
    FInfo: ICustomMVCServerInfo;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Initialize(const pServerInfo: ICustomMVCServerInfo);

    function GetInfo(): ICustomMVCServerInfo;

    procedure Start();
    procedure Stop();

    property Info: ICustomMVCServerInfo read GetInfo;
  end;

  TCustomMVCServerManager = class(TInterfacedObject, ICustomMVCServerManager)
  strict private
    FServers: TDictionary<string, ICustomMVCServer>;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure CreateServer(const pServerInfo: ICustomMVCServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, ICustomMVCServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): ICustomMVCServer;

    property Servers: TDictionary<string, ICustomMVCServer> read GetServers;
  end;

implementation

{ TCustomMVCUserAuthenticate }

procedure TCustomMVCUserAuthenticate.AfterConstruction;
begin
  inherited AfterConstruction;
  FUserName := EmptyStr;
  FPassword := EmptyStr;
  FApiKey := EmptyStr;
end;

procedure TCustomMVCUserAuthenticate.GenerateApiKey;
begin
  FApiKey := TCustomMVCCodification.HashSHA1(FUserName + FPassword);
end;

function TCustomMVCUserAuthenticate.GetApiKey: string;
begin
  Result := FApiKey;
end;

function TCustomMVCUserAuthenticate.GetPassword: string;
begin
  Result := FPassword;
end;

function TCustomMVCUserAuthenticate.GetUserName: string;
begin
  Result := FUserName;
end;

procedure TCustomMVCUserAuthenticate.SetPassword(const pValue: string);
begin
  FPassword := pValue;
  GenerateApiKey();
end;

procedure TCustomMVCUserAuthenticate.SetUserName(const pValue: string);
begin
  FUserName := pValue;
  GenerateApiKey();
end;

{ TCustomMVCAuthentication }

procedure TCustomMVCAuthentication.AddUser(const pUserName, pPassword: string);
var
  vUser: ICustomMVCUserAuthenticate;
begin
  vUser := TCustomMVC.NewUserAuthenticate;
  vUser.UserName := pUserName;
  vUser.Password := pPassword;
  FUsers.Add(vUser.ApiKey, vUser);
end;

procedure TCustomMVCAuthentication.AfterConstruction;
begin
  inherited AfterConstruction;
  FUsers := TDictionary<string, ICustomMVCUserAuthenticate>.Create;
end;

procedure TCustomMVCAuthentication.BeforeDestruction;
begin
  FreeAndNil(FUsers);
  inherited BeforeDestruction;
end;

function TCustomMVCAuthentication.CountUsers: Integer;
begin
  Result := FUsers.Count;
end;

procedure TCustomMVCAuthentication.RemoveUser(const pUserName, pPassword: string);
var
  vUser: ICustomMVCUserAuthenticate;
begin
  vUser := TCustomMVC.NewUserAuthenticate;
  vUser.UserName := pUserName;
  vUser.Password := pPassword;
  RemoveUser(vUser.ApiKey);
end;

procedure TCustomMVCAuthentication.RemoveUser(const pApiKey: string);
begin
  FUsers.Remove(pApiKey);
end;

function TCustomMVCAuthentication.UserIsValid(const pApiKey: string): Boolean;
begin
  Result := FUsers.ContainsKey(pApiKey);
end;

function TCustomMVCAuthentication.UserIsValid(const pUserName, pPassword: string): Boolean;
var
  vUser: ICustomMVCUserAuthenticate;
begin
  vUser := TCustomMVC.NewUserAuthenticate;
  vUser.UserName := pUserName;
  vUser.Password := pPassword;
  Result := UserIsValid(vUser.ApiKey);
end;

{ TCustomMVCServerInfo }

procedure TCustomMVCServerInfo.AfterConstruction;
begin
  inherited AfterConstruction;
  FServerName := EmptyStr;
  FPort := 0;
  FMaxConnections := 0;
  FWebModuleClass := nil;
end;

function TCustomMVCServerInfo.GetAuthentication: ICustomMVCAuthentication;
begin
  if (FAuthentication = nil) then
    raise ECustomMVCException.Create('Authentication was not created!');
  Result := FAuthentication;
end;

function TCustomMVCServerInfo.GetMaxConnections: Integer;
begin
  if (FMaxConnections = 0) then
    raise ECustomMVCException.Create('MaxConnections was not informed!');
  Result := FMaxConnections;
end;

function TCustomMVCServerInfo.GetPort: Integer;
begin
  if (FPort = 0) then
    raise ECustomMVCException.Create('Port was not informed!');
  Result := FPort;
end;

function TCustomMVCServerInfo.GetServerName: string;
begin
  if (FServerName = EmptyStr) then
    raise ECustomMVCException.Create('ServerName was not informed!');
  Result := FServerName;
end;

function TCustomMVCServerInfo.GetWebModuleClass: TComponentClass;
begin
  if (FWebModuleClass = nil) then
    raise ECustomMVCException.Create('WebModuleClass was not informed!');
  Result := FWebModuleClass;
end;

procedure TCustomMVCServerInfo.SetMaxConnections(const pValue: Integer);
begin
  FMaxConnections := pValue;
end;

procedure TCustomMVCServerInfo.SetPort(const pValue: Integer);
begin
  FPort := pValue;
end;

procedure TCustomMVCServerInfo.SetServerName(const pValue: string);
begin
  FServerName := pValue;
end;

procedure TCustomMVCServerInfo.SetWebModuleClass(const pValue: TComponentClass);
begin
  FWebModuleClass := pValue;
end;

{ TCustomMVCServer }

procedure TCustomMVCServer.AfterConstruction;
begin
  inherited AfterConstruction;
  FServer := TIdHTTPWebBrokerBridge.Create(nil);
  FInfo := nil;
end;

procedure TCustomMVCServer.BeforeDestruction;
begin
  FreeAndNil(FServer);
  inherited BeforeDestruction;
end;

function TCustomMVCServer.GetInfo: ICustomMVCServerInfo;
begin
  if (FInfo = nil) then
    raise ECustomMVCException.Create('ServerInfo was not informed!');

  Result := FInfo;
end;

procedure TCustomMVCServer.Initialize(const pServerInfo: ICustomMVCServerInfo);
begin
  if (pServerInfo = nil) then
    raise ECustomMVCException.Create('ServerInfo was not informed!');

  FInfo := pServerInfo;
  Stop();
  FServer.DefaultPort := FInfo.Port;
  FServer.MaxConnections := FInfo.MaxConnections;
  FServer.RegisterWebModuleClass(FInfo.WebModuleClass);
end;

procedure TCustomMVCServer.Start;
begin
  FServer.Active := True;
end;

procedure TCustomMVCServer.Stop;
begin
  FServer.Active := False;
end;

{ TCustomMVCServerManager }

procedure TCustomMVCServerManager.AfterConstruction;
begin
  inherited AfterConstruction;
  FServers := TDictionary<string, ICustomMVCServer>.Create;
end;

procedure TCustomMVCServerManager.BeforeDestruction;
begin
  StopServers();
  FreeAndNil(FServers);
  inherited BeforeDestruction;
end;

procedure TCustomMVCServerManager.CreateServer(const pServerInfo: ICustomMVCServerInfo);
var
  vServer: ICustomMVCServer;
  vPair: TPair<string, ICustomMVCServer>;
begin
  if not (FServers.ContainsKey(pServerInfo.ServerName)) then
  begin
    for vPair in FServers do
      if (vPair.Value.Info.WebModuleClass = pServerInfo.WebModuleClass) then
        raise ECustomMVCException.Create('Server List already contains ' + pServerInfo.WebModuleClass.ClassName + '!');

    vServer := ServiceLocator.GetService<ICustomMVCServer>;
    vServer.Initialize(pServerInfo);
    FServers.Add(pServerInfo.ServerName, vServer);
  end;
end;

procedure TCustomMVCServerManager.DestroyServer(const pServerName: string);
begin
  if (FServers.ContainsKey(pServerName)) then
    FServers.Remove(pServerName)
  else
    raise ECustomMVCException.Create('Server ' + pServerName + ' not found!');
end;

function TCustomMVCServerManager.FindServerByName(const pServerName: string): ICustomMVCServer;
begin
  Result := FServers.Items[pServerName];
end;

function TCustomMVCServerManager.GetServers: TDictionary<string, ICustomMVCServer>;
begin
  Result := FServers;
end;

procedure TCustomMVCServerManager.StartServers;
var
  vPair: TPair<string, ICustomMVCServer>;
begin
  for vPair in FServers do
    vPair.Value.Start();
end;

procedure TCustomMVCServerManager.StopServers;
var
  vPair: TPair<string, ICustomMVCServer>;
begin
  for vPair in FServers do
    vPair.Value.Stop();
end;

end.
