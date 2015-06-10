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
  Iocp.DSHTTPWebBroker,
  System.SyncObjs;

type

  ERESTSeverException = class(ERESTException);

  TRESTBridge = (rbIndy, rbIOCP);

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

    function GetBridge(): TRESTBridge;
    procedure SetBridge(const pValue: TRESTBridge);

    function GetSecurity(): IRESTSecurity;
    procedure SetSecurity(pValue: IRESTSecurity);

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Bridge: TRESTBridge read GetBridge write SetBridge;
    property Security: IRESTSecurity read GetSecurity write SetSecurity;
  end;

  TRESTServerInfoFactory = class sealed
  public
    class function Build(): IRESTServerInfo; static;
  end;

  IRESTServer = interface
    ['{95E91DF0-6ABF-46B1-B995-FC748BC54568}']
    function GetInfo(): IRESTServerInfo;

    procedure Initialize(pServerInfo: IRESTServerInfo);

    procedure Start();
    procedure Stop();

    property Info: IRESTServerInfo read GetInfo;
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

  TRESTController = MVCFramework.TMVCController;
  TRESTWebContext = MVCFramework.TWebContext;
  THTTPMethod = MVCFramework.TMVCHTTPMethodType;
  THTTPMethods = MVCFramework.TMVCHTTPMethods;
  HTTPMethodAttribute = MVCFramework.MVCHTTPMethodAttribute;
  StringValueAttribute = MVCFramework.MVCStringAttribute;
  ConsumesAttribute = MVCFramework.MVCConsumesAttribute;
  ProducesAttribute = MVCFramework.MVCProducesAttribute;
  PathAttribute = MVCFramework.MVCPathAttribute;

  TRESTEngine = class(TMVCEngine)
  strict private
    FServerName: string;
  public
    property ServerName: string read FServerName write FServerName;
  end;

  RESTServer = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Container(): IRESTServerContainer; static;
  end;

implementation

type

  TRESTSingletonServerContainer = class sealed
  strict private
    class var CriticalSection: TCriticalSection;
    class var ServerContainer: IRESTServerContainer;

    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance(): IRESTServerContainer; static;
  end;

  TRESTServerInfo = class(TInterfacedObject, IRESTServerInfo)
  strict private
    FServerName: string;
    FPort: Integer;
    FMaxConnections: Integer;
    FWebModuleClass: TComponentClass;
    FBridge: TRESTBridge;
    FSecurity: IRESTSecurity;

    function GetServerName(): string;
    procedure SetServerName(const pValue: string);

    function GetPort(): Integer;
    procedure SetPort(const pValue: Integer);

    function GetMaxConnections(): Integer;
    procedure SetMaxConnections(const pValue: Integer);

    function GetWebModuleClass(): TComponentClass;
    procedure SetWebModuleClass(pValue: TComponentClass);

    function GetBridge(): TRESTBridge;
    procedure SetBridge(const pValue: TRESTBridge);

    function GetSecurity(): IRESTSecurity;
    procedure SetSecurity(pValue: IRESTSecurity);
  public
    constructor Create();
    destructor Destroy(); override;

    property ServerName: string read GetServerName write SetServerName;
    property Port: Integer read GetPort write SetPort;
    property MaxConnections: Integer read GetMaxConnections write SetMaxConnections;
    property WebModuleClass: TComponentClass read GetWebModuleClass write SetWebModuleClass;
    property Bridge: TRESTBridge read GetBridge write SetBridge;
    property Security: IRESTSecurity read GetSecurity write SetSecurity;
  end;

  TRESTServer = class(TInterfacedObject, IRESTServer)
  strict private
    FIndyBridge: TIdHTTPWebBrokerBridge;
    FIOCPBridge: TIocpWebBrokerBridge;
    FInfo: IRESTServerInfo;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Initialize(pServerInfo: IRESTServerInfo);

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

    procedure CreateServer(pServerInfo: IRESTServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, IRESTServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): IRESTServer;

    property Servers: TDictionary<string, IRESTServer> read GetServers;
  end;

  { TRESTServerInfoFactory }

class function TRESTServerInfoFactory.Build: IRESTServerInfo;
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
  FBridge := TRESTBridge.rbIndy;
  FSecurity := nil;
end;

destructor TRESTServerInfo.Destroy;
begin

  inherited;
end;

function TRESTServerInfo.GetBridge: TRESTBridge;
begin
  Result := FBridge;
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

procedure TRESTServerInfo.SetBridge(const pValue: TRESTBridge);
begin
  FBridge := pValue;
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

{ TRESTServer }

constructor TRESTServer.Create;
begin
  FIndyBridge := nil;
  FIOCPBridge := nil;
  FInfo := nil;
end;

destructor TRESTServer.Destroy;
begin
  if (FIndyBridge <> nil) then
    FreeAndNil(FIndyBridge);

  if (FIOCPBridge <> nil) then
    FreeAndNil(FIOCPBridge);
  inherited;
end;

function TRESTServer.GetInfo: IRESTServerInfo;
begin
  if (FInfo = nil) then
    raise ERESTSeverException.Create('Server Info was not informed!');

  Result := FInfo;
end;

procedure TRESTServer.Initialize(pServerInfo: IRESTServerInfo);
begin
  if (pServerInfo = nil) then
    raise ERESTSeverException.Create('ServerInfo was not informed!');

  FInfo := pServerInfo;

  case FInfo.Bridge of
    rbIndy:
      begin
        FIndyBridge := TIdHTTPWebBrokerBridge.Create(nil);
        Stop();
        FIndyBridge.DefaultPort := FInfo.Port;
        FIndyBridge.MaxConnections := FInfo.MaxConnections;
        FIndyBridge.RegisterWebModuleClass(FInfo.WebModuleClass);
      end;
    rbIOCP:
      begin
        FIOCPBridge := TIocpWebBrokerBridge.Create(nil);
        Stop();
        FIOCPBridge.Port := FInfo.Port;
        FIOCPBridge.MaxClients := FInfo.MaxConnections;
        FIOCPBridge.RegisterWebModuleClass(FInfo.WebModuleClass);
      end;
  end;
end;

procedure TRESTServer.Start;
begin
  case FInfo.Bridge of
    rbIndy: FIndyBridge.Active := True;
    rbIOCP: FIOCPBridge.Active := True;
  end;
end;

procedure TRESTServer.Stop;
begin
  case FInfo.Bridge of
    rbIndy: FIndyBridge.Active := False;
    rbIOCP: FIOCPBridge.Active := False;
  end;
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
      ServerContainer := TRESTServerContainer.Create;
    finally
      CriticalSection.Leave;
    end;
  end;
  Result := ServerContainer;
end;

{ RESTServer }

class function RESTServer.Container: IRESTServerContainer;
begin
  Result := TRESTSingletonServerContainer.GetInstance();
end;

constructor RESTServer.Create;
begin
  raise ERESTSeverException.Create(CanNotBeInstantiatedException);
end;

end.
