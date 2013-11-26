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

unit CustomDMVC;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  MVCFramework,
  Web.HTTPApp,
  CustomDMVC.Codification;

type

  ECustomMVCException = class(Exception);

  ICustomMVCUserAuthenticate = interface
    ['{56A84057-56BB-4742-8ED2-6C5D47CA3E3A}']
    function GetUserName(): string;
    procedure SetUserName(const pValue: string);

    function GetPassword(): string;
    procedure SetPassword(const pValue: string);

    function GetApiKey(): string;

    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
    property ApiKey: string read GetApiKey;
  end;

  ICustomMVCAuthentication = interface
    ['{8A4C9CED-3291-4A43-8634-8FF7F0500778}']
    procedure AddUser(const pUserName, pPassword: string);

    procedure RemoveUser(const pUserName, pPassword: string); overload;
    procedure RemoveUser(const pApiKey: string); overload;

    function CountUsers(): Integer;

    function UserIsValid(const pUserName, pPassword: string): Boolean; overload;
    function UserIsValid(const pApiKey: string): Boolean; overload;
  end;

  ICustomMVCServerInfo = interface
    ['{3A328987-2485-4660-BB9B-B8AFFF47E4BA}']
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

  ICustomMVCServer = interface
    ['{95E91DF0-6ABF-46B1-B995-FC748BC54568}']
    procedure Initialize(const pServerInfo: ICustomMVCServerInfo);

    function GetInfo(): ICustomMVCServerInfo;

    procedure Start();
    procedure Stop();

    property Info: ICustomMVCServerInfo read GetInfo;
  end;

  ICustomMVCServerManager = interface
    ['{B20796A0-CB07-4D16-BEAB-4F0B10880318}']
    procedure CreateServer(const pServerInfo: ICustomMVCServerInfo);
    procedure DestroyServer(const pServerName: string);

    function GetServers(): TDictionary<string, ICustomMVCServer>;

    procedure StartServers();
    procedure StopServers();

    function FindServerByName(const pServerName: string): ICustomMVCServer;

    property Servers: TDictionary<string, ICustomMVCServer> read GetServers;
  end;

  TCustomMVCController = class(TMVCController);

  TCustomMVCEngine = class(TMVCEngine)
  strict private
    FServerName: string;
    function GetServerAuthentication(): ICustomMVCAuthentication;
    function Authenticate(const pRequest: TWebRequest): Boolean;
  protected
    function ExecuteAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse): Boolean; override;
  public
    property ServerName: string read FServerName write FServerName;
  end;

  TCustomMVC = class
  public
    class function NewUserAuthenticate(): ICustomMVCUserAuthenticate; static;
    class function NewAuthentication(): ICustomMVCAuthentication; static;
    class function NewServerInfo(): ICustomMVCServerInfo; static;
    class function ServerManager(): ICustomMVCServerManager; static;
  end;

implementation

uses
  Spring,
  Spring.Services;

{ TCustomMVC }

class function TCustomMVC.NewAuthentication: ICustomMVCAuthentication;
begin
  Result := ServiceLocator.GetService<ICustomMVCAuthentication>;
end;

class function TCustomMVC.NewServerInfo: ICustomMVCServerInfo;
begin
  Result := ServiceLocator.GetService<ICustomMVCServerInfo>;
end;

class function TCustomMVC.NewUserAuthenticate: ICustomMVCUserAuthenticate;
begin
  Result := ServiceLocator.GetService<ICustomMVCUserAuthenticate>;
end;

class function TCustomMVC.ServerManager: ICustomMVCServerManager;
begin
  Result := ServiceLocator.GetService<ICustomMVCServerManager>;
end;

{ TCustomMVCEngine }

function TCustomMVCEngine.Authenticate(const pRequest: TWebRequest): Boolean;

  function ContainsAuthorization(): Boolean;
  begin
    try
      Result := (pRequest.Authorization <> EmptyStr);
    except
      Result := False;
    end;
  end;

  function ContainsApiKey(): Boolean;
  begin
    try
      Result := (pRequest.GetFieldByName('ApiKey') <> EmptyStr);
    except
      Result := False;
    end;
  end;

  function DecodeAuthorization(): string;
  begin
    try
      Result := pRequest.Authorization;
      Result := TCustomMVCCodification.DecodeBase64(Copy(Result, Pos(' ', Result) + 1, Length(Result)));
    except
      Result := EmptyStr;
    end;
  end;

  function DecodeApiKey(): string;
  begin
    try
      Result := pRequest.GetFieldByName('ApiKey');
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

function TCustomMVCEngine.ExecuteAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse): Boolean;
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

function TCustomMVCEngine.GetServerAuthentication: ICustomMVCAuthentication;
begin
  Result := TCustomMVC.ServerManager.FindServerByName(FServerName).Info.Authentication;
end;

end.
