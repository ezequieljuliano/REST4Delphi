(*
  Copyright 2014 Ezequiel Juliano Müller - ezequieljuliano@gmail.com

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

unit REST4D.Server;

interface

uses
  REST4D,
  System.SysUtils,
  System.Classes,
  MVCFramework,
  System.Generics.Collections,
  Web.HTTPApp,
  IdHTTPWebBrokerBridge,
  System.SyncObjs;

type

  ERESTSeverException = class(ERESTException);

  IRESTServerInfo = interface
    ['{3A328987-2485-4660-BB9B-B8AFFF47E4BA}']
    function GetServerName(): string;
    procedure SetServerName(const pValue: string);

    function GetPort(): Integer;
    procedure SetPort(const pValue: Integer);

    function GetMaxConnections(): Integer;
    procedure SetMaxConnections(const pValue: Integer);

    function GetWebModuleClass(): TComponentClass;
    procedure SetWebModuleClass(const pValue: TComponentClass);

    function GetAuthentication(): IRESTAuthentication;

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Authentication: IRESTAuthentication read GetAuthentication;
  end;

  TRESTServerInfoFactory = class sealed
  public
    class function GetInstance(): IRESTServerInfo; static;
  end;

  IRESTServer = interface
    ['{95E91DF0-6ABF-46B1-B995-FC748BC54568}']
    procedure Initialize(const pServerInfo: IRESTServerInfo);

    function GetInfo(): IRESTServerInfo;

    procedure Start();
    procedure Stop();

    property Info: IRESTServerInfo read GetInfo;
  end;

  IRESTServerContainer = interface
    ['{B20796A0-CB07-4D16-BEAB-4F0B10880318}']
    procedure CreateServer(const pServerInfo: IRESTServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, IRESTServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): IRESTServer;

    property Servers: TDictionary<string, IRESTServer> read GetServers;
  end;

  TRESTServerContainerFactory = class sealed
  public
    class function GetSingleton(): IRESTServerContainer; static;
  end;

  TRESTController = class(TMVCController);

  TRESTEngine = class(TMVCEngine)
  strict private
    FServerName: string;
    function GetServerAuthentication(): IRESTAuthentication;
    function Authenticate(const pRequest: TWebRequest): Boolean;
  protected
    function ExecuteAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse): Boolean; override;
  public
    property ServerName: string read FServerName write FServerName;
  end;

implementation

var
  _vCSection: TCriticalSection = nil;
  _vRESTServerContainer: IRESTServerContainer = nil;

type

  TRESTServerInfo = class(TInterfacedObject, IRESTServerInfo)
  strict private
    FServerName: string;
    FPort: Integer;
    FMaxConnections: Integer;
    FWebModuleClass: TComponentClass;
    FAuthentication: IRESTAuthentication;
  public
    constructor Create();
    destructor Destroy(); override;

    function GetServerName(): string;
    procedure SetServerName(const pValue: string);

    function GetPort(): Integer;
    procedure SetPort(const pValue: Integer);

    function GetMaxConnections(): Integer;
    procedure SetMaxConnections(const pValue: Integer);

    function GetWebModuleClass(): TComponentClass;
    procedure SetWebModuleClass(const pValue: TComponentClass);

    function GetAuthentication(): IRESTAuthentication;

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Authentication: IRESTAuthentication read GetAuthentication;
  end;

  TRESTServer = class(TInterfacedObject, IRESTServer)
  strict private
    FServer: TIdHTTPWebBrokerBridge;
    FInfo: IRESTServerInfo;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Initialize(const pServerInfo: IRESTServerInfo);

    function GetInfo(): IRESTServerInfo;

    procedure Start();
    procedure Stop();

    property Info: IRESTServerInfo read GetInfo;
  end;

  TRESTServerContainer = class(TInterfacedObject, IRESTServerContainer)
  strict private
    FServers: TDictionary<string, IRESTServer>;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure CreateServer(const pServerInfo: IRESTServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, IRESTServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): IRESTServer;

    property Servers: TDictionary<string, IRESTServer> read GetServers;
  end;

{ TRESTEngine }

function TRESTEngine.Authenticate(const pRequest: TWebRequest): Boolean;
  function ContainsAuthorization(): Boolean;
  begin
    try
      Result := (pRequest.Authorization <> AnsiString(EmptyStr));
    except
      Result := False;
    end;
  end;

  function ContainsApiKey(): Boolean;
  begin
    try
      Result := (pRequest.GetFieldByName(AnsiString('ApiKey')) <> AnsiString(EmptyStr));
    except
      Result := False;
    end;
  end;

  function DecodeAuthorization(): string;
  begin
    try
      Result := string(pRequest.Authorization);
      Result := TRESTCodification.DecodeBase64(Copy(Result, Pos(' ', Result) + 1, Length(Result)));
    except
      Result := EmptyStr;
    end;
  end;

  function DecodeApiKey(): string;
  begin
    try
      Result := string(pRequest.GetFieldByName(AnsiString('ApiKey')));
    except
      Result := EmptyStr;
    end;
  end;

var
  vUserName, vPassword, vDecode: string;
begin
  Result := True;
  if (GetServerAuthentication.CountUsers > 0) then
  begin
    Result := False;
    if ContainsAuthorization() then
    begin
      vDecode := DecodeAuthorization();
      if (vDecode <> EmptyStr) then
      begin
        vUserName := Copy(vDecode, 1, Pos(':', vDecode) - 1);
        vPassword := Copy(vDecode, Pos(':', vDecode) + 1, Length(vDecode));
        Result := GetServerAuthentication.UserIsValid(vUserName, vPassword);
      end;
    end
    else if ContainsApiKey() then
    begin
      vDecode := DecodeApiKey();
      if (vDecode <> EmptyStr) then
        Result := GetServerAuthentication.UserIsValid(vDecode);
    end;
  end;
end;

function TRESTEngine.ExecuteAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse): Boolean;
begin
  Result := False;
  if Authenticate(Request) then
    inherited ExecuteAction(Sender, Request, Response)
  else
  begin
    Response.StatusCode := 401;
    Response.ReasonString := 'Unauthorized';
    Response.Content := 'Unauthorized';
  end;
end;

function TRESTEngine.GetServerAuthentication: IRESTAuthentication;
begin
  Result := TRESTServerContainerFactory.GetSingleton.FindServerByName(FServerName).Info.Authentication;
end;

{ TRESTServerInfoFactory }

class function TRESTServerInfoFactory.GetInstance: IRESTServerInfo;
begin
  Result := TRESTServerInfo.Create;
end;

{ TRESTServerInfo }

constructor TRESTServerInfo.Create;
begin
  FServerName := EmptyStr;
  FPort := 0;
  FMaxConnections := 0;
  FWebModuleClass := nil;
  FAuthentication := TRESTUserAuthenticationFactory.GetInstance;
end;

destructor TRESTServerInfo.Destroy;
begin

  inherited;
end;

function TRESTServerInfo.GetAuthentication: IRESTAuthentication;
begin
  if (FAuthentication = nil) then
    raise ERESTSeverException.Create('Authentication was not created!');
  Result := FAuthentication;
end;

function TRESTServerInfo.GetMaxConnections: Integer;
begin
  if (FMaxConnections = 0) then
    raise ERESTSeverException.Create('MaxConnections was not informed!');
  Result := FMaxConnections;
end;

function TRESTServerInfo.GetPort: Integer;
begin
  if (FPort = 0) then
    raise ERESTSeverException.Create('Port was not informed!');
  Result := FPort;
end;

function TRESTServerInfo.GetServerName: string;
begin
  if (FServerName = EmptyStr) then
    raise ERESTSeverException.Create('ServerName was not informed!');
  Result := FServerName;
end;

function TRESTServerInfo.GetWebModuleClass: TComponentClass;
begin
  if (FWebModuleClass = nil) then
    raise ERESTSeverException.Create('WebModuleClass was not informed!');
  Result := FWebModuleClass;
end;

procedure TRESTServerInfo.SetMaxConnections(const pValue: Integer);
begin
  FMaxConnections := pValue;
end;

procedure TRESTServerInfo.SetPort(const pValue: Integer);
begin
  FPort := pValue;
end;

procedure TRESTServerInfo.SetServerName(const pValue: string);
begin
  FServerName := pValue;
end;

procedure TRESTServerInfo.SetWebModuleClass(const pValue: TComponentClass);
begin
  FWebModuleClass := pValue;
end;

{ TRESTServer }

constructor TRESTServer.Create;
begin
  FServer := TIdHTTPWebBrokerBridge.Create(nil);
  FInfo := nil;
end;

destructor TRESTServer.Destroy;
begin
  FreeAndNil(FServer);
  inherited;
end;

function TRESTServer.GetInfo: IRESTServerInfo;
begin
  if (FInfo = nil) then
    raise ERESTSeverException.Create('Server Info was not informed!');

  Result := FInfo;
end;

procedure TRESTServer.Initialize(const pServerInfo: IRESTServerInfo);
begin
  if (pServerInfo = nil) then
    raise ERESTSeverException.Create('ServerInfo was not informed!');

  FInfo := pServerInfo;

  Stop();

  FServer.DefaultPort := FInfo.Port;
  FServer.MaxConnections := FInfo.MaxConnections;
  FServer.RegisterWebModuleClass(FInfo.WebModuleClass);
end;

procedure TRESTServer.Start;
begin
  FServer.Active := True;
end;

procedure TRESTServer.Stop;
begin
  FServer.Active := False;
end;

{ TRESTServerContainer }

constructor TRESTServerContainer.Create;
begin
  FServers := TDictionary<string, IRESTServer>.Create;
end;

procedure TRESTServerContainer.CreateServer(const pServerInfo: IRESTServerInfo);
var
  vServer: IRESTServer;
  vPair: TPair<string, IRESTServer>;
begin
  if not (FServers.ContainsKey(pServerInfo.ServerName)) then
  begin
    for vPair in FServers do
      if (vPair.Value.Info.WebModuleClass = pServerInfo.WebModuleClass) then
        raise ERESTSeverException.Create('Server List already contains ' + pServerInfo.WebModuleClass.ClassName + '!');

    vServer := TRESTServer.Create;
    vServer.Initialize(pServerInfo);
    FServers.Add(pServerInfo.ServerName, vServer);
  end;
end;

destructor TRESTServerContainer.Destroy;
begin
  StopServers();
  FreeAndNil(FServers);
  inherited;
end;

procedure TRESTServerContainer.DestroyServer(const pServerName: string);
begin
  if (FServers.ContainsKey(pServerName)) then
    FServers.Remove(pServerName)
  else
    raise ERESTSeverException.Create('Server ' + pServerName + ' not found!');
end;

function TRESTServerContainer.FindServerByName(const pServerName: string): IRESTServer;
begin
  try
    Result := FServers.Items[pServerName];
  except
    Result := nil;
  end;
end;

function TRESTServerContainer.GetServers: TDictionary<string, IRESTServer>;
begin
  Result := FServers;
end;

procedure TRESTServerContainer.StartServers;
var
  vPair: TPair<string, IRESTServer>;
begin
  for vPair in FServers do
    vPair.Value.Start();
end;

procedure TRESTServerContainer.StopServers;
var
  vPair: TPair<string, IRESTServer>;
begin
  for vPair in FServers do
    vPair.Value.Stop();
end;

{ TRESTServerContainerFactory }

class function TRESTServerContainerFactory.GetSingleton: IRESTServerContainer;
begin
  if (_vRESTServerContainer = nil) then
  begin
    _vCSection.Enter;
    try
      _vRESTServerContainer := TRESTServerContainer.Create;
    finally
      _vCSection.Leave;
    end;
  end;
  Result := _vRESTServerContainer;
end;

initialization

_vCSection := TCriticalSection.Create();

finalization

_vRESTServerContainer := nil;

FreeAndNil(_vCSection);

end.
