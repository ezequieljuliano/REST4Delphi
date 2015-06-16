unit REST4D.Server;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  REST4D

  {$IFDEF IOCP},

  Iocp.DSHTTPWebBroker

  {$ELSE},

  IdHTTPWebBrokerBridge

  {$ENDIF},

  MVCFramework;

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
    procedure SetWebModuleClass(pValue: TComponentClass);

    function GetSecurity(): IRESTSecurity;
    procedure SetSecurity(pValue: IRESTSecurity);

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Security: IRESTSecurity read GetSecurity write SetSecurity;
  end;

  TRESTServerInfoFactory = class sealed
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Build(): IRESTServerInfo; static;
  end;

  IRESTServer = interface
    ['{95E91DF0-6ABF-46B1-B995-FC748BC54568}']
    function GetInfo(): IRESTServerInfo;

    procedure Start();
    procedure Stop();

    property Info: IRESTServerInfo read GetInfo;
  end;

  TRESTServerFactory = class sealed
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Build(pServerInfo: IRESTServerInfo): IRESTServer; static;
  end;

  IRESTServerContainer = interface
    ['{B20796A0-CB07-4D16-BEAB-4F0B10880318}']
    function GetServers(): TDictionary<string, IRESTServer>;

    procedure CreateServer(pServerInfo: IRESTServerInfo);
    procedure DestroyServer(const pServerName: string);

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): IRESTServer;

    property Servers: TDictionary<string, IRESTServer> read GetServers;
  end;

  TRESTServerContainerFactory = class sealed
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Build(): IRESTServerContainer; static;
  end;

  TRESTEngine = MVCFramework.TMVCEngine;
  TRESTController = MVCFramework.TMVCController;
  TRESTWebContext = MVCFramework.TWebContext;

  THTTPMethod = MVCFramework.TMVCHTTPMethodType;
  THTTPMethods = MVCFramework.TMVCHTTPMethods;

  HTTPMethodAttribute = MVCFramework.MVCHTTPMethodAttribute;
  StringValueAttribute = MVCFramework.MVCStringAttribute;
  ConsumesAttribute = MVCFramework.MVCConsumesAttribute;
  ProducesAttribute = MVCFramework.MVCProducesAttribute;
  PathAttribute = MVCFramework.MVCPathAttribute;

  RESTServerDefault = class sealed
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Container(): IRESTServerContainer; static;
  end;

implementation

const
  _CanNotBeInstantiatedException = 'This class can not be instantiated!';

type

  TRESTServerInfo = class(TInterfacedObject, IRESTServerInfo)
  strict private
    FServerName: string;
    FPort: Integer;
    FMaxConnections: Integer;
    FWebModuleClass: TComponentClass;
    FSecurity: IRESTSecurity;

    function GetServerName(): string;
    procedure SetServerName(const pValue: string);

    function GetPort(): Integer;
    procedure SetPort(const pValue: Integer);

    function GetMaxConnections(): Integer;
    procedure SetMaxConnections(const pValue: Integer);

    function GetWebModuleClass(): TComponentClass;
    procedure SetWebModuleClass(pValue: TComponentClass);

    function GetSecurity(): IRESTSecurity;
    procedure SetSecurity(pValue: IRESTSecurity);
  public
    constructor Create();
    destructor Destroy(); override;

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Security: IRESTSecurity read GetSecurity write SetSecurity;
  end;

  TRESTServer = class(TInterfacedObject, IRESTServer)
  strict private

    {$IFDEF IOCP}

    FBridge: TIocpWebBrokerBridge;

    {$ELSE}

    FBridge: TIdHTTPWebBrokerBridge;

    {$ENDIF}

    FInfo: IRESTServerInfo;
  strict private
    function GetInfo(): IRESTServerInfo;
    procedure Configuration(pServerInfo: IRESTServerInfo);
  public
    constructor Create(pServerInfo: IRESTServerInfo);
    destructor Destroy(); override;

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

    procedure CreateServer(pServerInfo: IRESTServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, IRESTServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): IRESTServer;

    property Servers: TDictionary<string, IRESTServer> read GetServers;
  end;

  TRESTSingletonServerContainer = class sealed
  strict private
    class var CriticalSection: TCriticalSection;
    class var ServerContainer: IRESTServerContainer;

    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance(): IRESTServerContainer; static;
  end;

  { TRESTServerInfo }

constructor TRESTServerInfo.Create;
begin
  FServerName := EmptyStr;
  FPort := 0;
  FMaxConnections := 0;
  FWebModuleClass := nil;
  FSecurity := nil;
end;

destructor TRESTServerInfo.Destroy;
begin

  inherited;
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

function TRESTServerInfo.GetSecurity: IRESTSecurity;
begin
  Result := FSecurity;
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

procedure TRESTServerInfo.SetSecurity(pValue: IRESTSecurity);
begin
  FSecurity := pValue;
end;

procedure TRESTServerInfo.SetServerName(const pValue: string);
begin
  FServerName := pValue;
end;

procedure TRESTServerInfo.SetWebModuleClass(pValue: TComponentClass);
begin
  FWebModuleClass := pValue;
end;

{ TRESTServerInfoFactory }

class function TRESTServerInfoFactory.Build: IRESTServerInfo;
begin
  Result := TRESTServerInfo.Create;
end;

constructor TRESTServerInfoFactory.Create;
begin
  raise ERESTSeverException.Create(_CanNotBeInstantiatedException);
end;

{ TRESTServer }

constructor TRESTServer.Create(pServerInfo: IRESTServerInfo);
begin
  Configuration(pServerInfo);
end;

destructor TRESTServer.Destroy;
begin
  if (FBridge <> nil) then
    FreeAndNil(FBridge);
  inherited;
end;

function TRESTServer.GetInfo: IRESTServerInfo;
begin
  if (FInfo = nil) then
    raise ERESTSeverException.Create('Server Info was not informed!');

  Result := FInfo;
end;

procedure TRESTServer.Configuration(pServerInfo: IRESTServerInfo);
begin
  if (pServerInfo = nil) then
    raise ERESTSeverException.Create('ServerInfo was not informed!');

  FInfo := pServerInfo;

  {$IFDEF IOCP}

  FBridge := TIocpWebBrokerBridge.Create(nil);
  Stop();
  FBridge.Port := FInfo.Port;
  FBridge.MaxClients := FInfo.MaxConnections;
  FBridge.RegisterWebModuleClass(FInfo.WebModuleClass);

  {$ELSE}

  FBridge := TIdHTTPWebBrokerBridge.Create(nil);
  Stop();
  FBridge.DefaultPort := FInfo.Port;
  FBridge.MaxConnections := FInfo.MaxConnections;
  FBridge.RegisterWebModuleClass(FInfo.WebModuleClass);

  {$ENDIF}

end;

procedure TRESTServer.Start;
begin
  FBridge.Active := True;
end;

procedure TRESTServer.Stop;
begin
  FBridge.Active := False;
end;

{ TRESTServerFactory }

class function TRESTServerFactory.Build(pServerInfo: IRESTServerInfo): IRESTServer;
begin
  Result := TRESTServer.Create(pServerInfo);
end;

constructor TRESTServerFactory.Create;
begin
  raise ERESTSeverException.Create(_CanNotBeInstantiatedException);
end;

{ TRESTServerContainer }

constructor TRESTServerContainer.Create;
begin
  FServers := TDictionary<string, IRESTServer>.Create;
end;

procedure TRESTServerContainer.CreateServer(pServerInfo: IRESTServerInfo);
var
  vServer: IRESTServer;
  vPair: TPair<string, IRESTServer>;
begin
  if not(FServers.ContainsKey(pServerInfo.ServerName)) then
  begin
    for vPair in FServers do
      if (vPair.Value.Info.WebModuleClass = pServerInfo.WebModuleClass) then
        raise ERESTSeverException.Create('Server List already contains ' + pServerInfo.WebModuleClass.ClassName + '!');

    vServer := TRESTServerFactory.Build(pServerInfo);
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

class function TRESTServerContainerFactory.Build: IRESTServerContainer;
begin
  Result := TRESTServerContainer.Create;
end;

constructor TRESTServerContainerFactory.Create;
begin
  raise ERESTSeverException.Create(_CanNotBeInstantiatedException);
end;

{ TRESTSingletonServerContainer }

class constructor TRESTSingletonServerContainer.Create;
begin
  CriticalSection := TCriticalSection.Create();
  ServerContainer := nil;
end;

class destructor TRESTSingletonServerContainer.Destroy;
begin
  ServerContainer := nil;
  FreeAndNil(CriticalSection);
end;

class function TRESTSingletonServerContainer.GetInstance: IRESTServerContainer;
begin
  if (ServerContainer = nil) then
  begin
    CriticalSection.Enter;
    try
      ServerContainer := TRESTServerContainerFactory.Build();
    finally
      CriticalSection.Leave;
    end;
  end;
  Result := ServerContainer;
end;

{ RESTServerDefault }

class function RESTServerDefault.Container: IRESTServerContainer;
begin
  Result := TRESTSingletonServerContainer.GetInstance();
end;

constructor RESTServerDefault.Create;
begin
  raise ERESTSeverException.Create(_CanNotBeInstantiatedException);
end;

end.
