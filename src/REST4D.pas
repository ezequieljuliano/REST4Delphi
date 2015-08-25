unit REST4D;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  MVCFramework.Commons,
  MVCFramework.Middleware.Authentication;

type

  ERESTException = class(Exception);

  TRESTMediaType = class sealed
  public const
    APPLICATION_ATOM_XML = 'application/atom+xml';
    APPLICATION_FORM_URLENCODED = 'application/x-www-form-urlencoded';
    APPLICATION_JSON = 'application/json';
    APPLICATION_OCTET_STREAM = 'application/octet-stream';
    APPLICATION_SVG_XML = 'application/svg+xml';
    APPLICATION_XHTML_XML = 'application/xhtml+xml';
    APPLICATION_XML = 'application/xml';
    MEDIA_TYPE_WILDCARD = '*';
    MULTIPART_FORM_DATA = 'multipart/form-data';
    TEXT_HTML = 'text/html';
    TEXT_PLAIN = 'text/plain';
    TEXT_XML = 'text/xml';
    WILDCARD = '*/*';
  end;

  TRESTCharSet = class sealed
  public const
    ISO88591 = 'iso-8859-1';
    ISO88592 = 'iso-8859-2';
    ISO88593 = 'iso-8859-3';
    ISO88594 = 'iso-8859-4';
    ISO88595 = 'iso-8859-5';
    ISO88596 = 'iso-8859-6';
    ISO88597 = 'iso-8859-7';
    ISO88598 = 'iso-8859-8';
    ISO885915 = 'iso-8859-15';
    WINDOWS1250 = 'windows-1250';
    WINDOWS1251 = 'windows-1251';
    WINDOWS1252 = 'windows-1252';
    WINDOWS1254 = 'windows-1254';
    UTF8 = 'utf-8';
  end;

  TRESTStatusCode = class sealed
  public const
    // 2xx Success
    OK = 200;
    CREATED = 201;
    ACCEPTED = 202;
    NO_CONTENT = 204;
    // 3xx Redirection
    NOT_MODIFIED = 304;
    // 4xx Client Error
    BAD_REQUEST = 400;
    UNAUTHORIZED = 401;
    FORBIDDEN = 403;
    NOT_FOUND = 404;
    CONFLICT = 409;
    UNSUPPORTED_MEDIA_TYPE = 415;
    // 5xx Server Error
    INTERNAL_SERVER_ERROR = 500;
    NOT_IMPLEMENTED = 501;
  end;

  IRESTSecurity = MVCFramework.Commons.IMVCAuthenticationHandler;
  TRESTBasicAuthenticationMiddleware = MVCFramework.Middleware.Authentication.TMVCBasicAuthenticationMiddleware;

  TRESTBaseSecurity = class abstract(TInterfacedObject)
  strict private
    { private declarations }
  strict protected
    { protected declarations }
  public
    { public declarations }
  end;

  TRESTAuthenticationDelegate = reference to procedure(const pUserName, pPassword: string;
    pUserRoles: TList<string>; var pIsValid: Boolean);

  TRESTAuthorizationDelegate = reference to procedure(pUserRoles: TList<string>;
    const pControllerQualifiedClassName: string; const pActionName: string; var pIsAuthorized: Boolean);

  TRESTDefaultSecurity = class(TRESTBaseSecurity, IRESTSecurity)
  strict private
    FAuthenticationDelegate: TRESTAuthenticationDelegate;
    FAuthorizationDelegate: TRESTAuthorizationDelegate;
  public
    constructor Create(pAuthenticationDelegate: TRESTAuthenticationDelegate;
      pAuthorizationDelegate: TRESTAuthorizationDelegate);

    procedure OnRequest(const ControllerQualifiedClassName, ActionName: string;
      var AuthenticationRequired: Boolean);

    procedure OnAuthentication(const UserName, Password: string; UserRoles: TList<string>;
      var IsValid: Boolean);

    procedure OnAuthorization(UserRoles: TList<string>; const ControllerQualifiedClassName: string;
      const ActionName: string; var IsAuthorized: Boolean);
  end;

implementation

{ TRESTDefaultSecurity }

constructor TRESTDefaultSecurity.Create(pAuthenticationDelegate: TRESTAuthenticationDelegate;
  pAuthorizationDelegate: TRESTAuthorizationDelegate);
begin
  FAuthenticationDelegate := pAuthenticationDelegate;
  FAuthorizationDelegate := pAuthorizationDelegate;
end;

procedure TRESTDefaultSecurity.OnAuthentication(const UserName, Password: string;
  UserRoles: TList<string>; var IsValid: Boolean);
begin
  IsValid := True;
  if Assigned(FAuthenticationDelegate) then
    FAuthenticationDelegate(UserName, Password, UserRoles, IsValid);
end;

procedure TRESTDefaultSecurity.OnAuthorization(UserRoles: TList<string>;
  const ControllerQualifiedClassName, ActionName: string; var IsAuthorized: Boolean);
begin
  IsAuthorized := True;
  if Assigned(FAuthorizationDelegate) then
    FAuthorizationDelegate(UserRoles, ControllerQualifiedClassName, ActionName, IsAuthorized);
end;

procedure TRESTDefaultSecurity.OnRequest(const ControllerQualifiedClassName, ActionName: string;
  var AuthenticationRequired: Boolean);
begin
  AuthenticationRequired := True;
end;

end.
