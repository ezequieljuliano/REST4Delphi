unit REST4D.Client;

interface

uses
  REST4D,
  MVCFramework.RESTClient,
  ObjectsMappers,
  System.Generics.Collections,
  System.SysUtils,
  System.StrUtils,
  {$IF CompilerVersion < 27}
  Data.DBXJSON,
  {$ELSE}
  System.JSON,
  {$IFEND}
  IdURI;

type

  ERESTClientException = class(ERESTException);

  TRESTfulResponse = class
  strict private
    FRESTResponse: IRESTResponse;
  private
    procedure SetRESTResponse(const pResponse: IRESTResponse);
    function GetRESTResponse(): IRESTResponse;
  public
    constructor Create();

    function AsString(): string;
    function AsJSONValue(): TJSONValue;
    function AsJSONObject(): TJSONObject;
    function AsObject<TResponseType: class, constructor>(): TResponseType;
    function AsObjectList<TResponseType: class, constructor>(): TObjectList<TResponseType>;

    function StatusCode(): Word;
    function StatusText(): string;
  end;

  TRESTfulClient = class
  strict private
    FRESTClient: TRESTClient;
    FRESTResponse: TRESTfulResponse;
    FResource: string;
    FParams: array of string;
  public
    constructor Create(const pHost: string; const pPort: Word = 80);
    destructor Destroy; override;

    function ReadTimeOut(const pReadTimeOut: Cardinal): TRESTfulClient;
    function ConnectionTimeOut(const pConnectionTimeOut: Cardinal): TRESTfulClient;
    function Authorization(const pUser, pPassword: string): TRESTfulClient;
    function ApiKey(const pApiKey: string): TRESTfulClient;
    function ClearHeaders(): TRESTfulClient;
    function Header(const pField, pValue: string): TRESTfulClient;
    function Accept(const pAcceptType: string): TRESTfulClient;
    function AcceptCharSet(const pCharsetType: string): TRESTfulClient;
    function ContentType(const pContentType: string): TRESTfulClient;
    function ContentCharSet(const pCharsetType: string): TRESTfulClient;
    function Resource(const pResource: string): TRESTfulClient;
    function Params(const pParams: array of string): TRESTfulClient;
    function SSL(const pEnabled: Boolean = True): TRESTfulClient;
    function Compression(const pEnabled: Boolean = True): TRESTfulClient;

    function GET(): TRESTfulResponse;

    function POST(const pBody: string): TRESTfulResponse; overload;
    function POST(const pBody: TJSONValue; const pBodyFree: Boolean = True): TRESTfulResponse; overload;
    function POST<TBodyType: class>(const pBody: TBodyType; const pBodyFree: Boolean = True): TRESTfulResponse; overload;
    function POST<TBodyType: class>(const pBody: TObjectList<TBodyType>; const pBodyFree: Boolean = True): TRESTfulResponse; overload;

    function PUT(const pBody: string): TRESTfulResponse; overload;
    function PUT(const pBody: TJSONValue; const pBodyFree: Boolean = True): TRESTfulResponse; overload;
    function PUT<TBodyType: class>(const pBody: TBodyType; const pBodyFree: Boolean = True): TRESTfulResponse; overload;
    function PUT<TBodyType: class>(const pBody: TObjectList<TBodyType>; const pBodyFree: Boolean = True): TRESTfulResponse; overload;

    function DELETE(): TRESTfulResponse; overload;

    property DefaultClient: TRESTClient read FRESTClient;
  end;

implementation

{ TRESTfulClient }

function TRESTfulClient.Accept(const pAcceptType: string): TRESTfulClient;
begin
  FRESTClient.Accept(pAcceptType);
  Result := Self;
end;

function TRESTfulClient.AcceptCharSet(const pCharsetType: string): TRESTfulClient;
begin
  if FRESTClient.Accept().IsEmpty then
    raise ERESTClientException.Create('First set the Accept property!');

  if not AnsiContainsText(FRESTClient.Accept(), 'charset') then
    FRESTClient.Accept(FRESTClient.Accept() + ';charset=' + pCharsetType);

  Result := Self;
end;

function TRESTfulClient.ApiKey(const pApiKey: string): TRESTfulClient;
begin
  FRESTClient.RequestHeaders.Add('ApiKey=' + pApiKey);
  Result := Self;
end;

function TRESTfulClient.Authorization(const pUser, pPassword: string): TRESTfulClient;
var
  vAuthorization: string;
begin
  vAuthorization := TRESTCodification.EncodeBase64(pUser + ':' + pPassword);
  FRESTClient.RequestHeaders.Add('Authorization=Basic ' + vAuthorization);
  Result := Self;
end;

function TRESTfulClient.ClearHeaders: TRESTfulClient;
begin
  FRESTClient.RequestHeaders.Clear;
  Result := Self;
end;

function TRESTfulClient.Compression(const pEnabled: Boolean): TRESTfulClient;
begin
  FRESTClient.Compression(pEnabled);
  Result := Self;
end;

function TRESTfulClient.ConnectionTimeOut(const pConnectionTimeOut: Cardinal): TRESTfulClient;
begin
  FRESTClient.ConnectionTimeOut := pConnectionTimeOut;
  Result := Self;
end;

function TRESTfulClient.ContentType(const pContentType: string): TRESTfulClient;
begin
  FRESTClient.ContentType(pContentType);
  Result := Self;
end;

function TRESTfulClient.ContentCharSet(const pCharsetType: string): TRESTfulClient;
begin
  if FRESTClient.ContentType().IsEmpty then
    raise ERESTClientException.Create('First set the ContentType property!');

  if not AnsiContainsText(FRESTClient.ContentType(), 'charset') then
    FRESTClient.ContentType(FRESTClient.ContentType() + ';charset=' + pCharsetType);

  Result := Self;
end;

constructor TRESTfulClient.Create(const pHost: string; const pPort: Word);
begin
  FRESTClient := TRESTClient.Create(pHost, pPort);
  FRESTResponse := TRESTfulResponse.Create;
  FResource := EmptyStr;
  SetLength(FParams, 0);
end;

function TRESTfulClient.DELETE: TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doDELETE(FResource, FParams)
    );
  Result := FRESTResponse;
end;

destructor TRESTfulClient.Destroy;
begin
  if (FRESTClient <> nil) then
    FreeAndNil(FRESTClient);
  if (FRESTResponse <> nil) then
    FreeAndNil(FRESTResponse);
  inherited;
end;

function TRESTfulClient.GET: TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doGET(FResource, FParams)
    );
  Result := FRESTResponse;
end;

function TRESTfulClient.Header(const pField, pValue: string): TRESTfulClient;
begin
  FRESTClient.RequestHeaders.Add(pField + '=' + pValue);
  Result := Self;
end;

function TRESTfulClient.Params(const pParams: array of string): TRESTfulClient;
var
  I: Integer;
begin
  SetLength(FParams, Length(pParams));
  for I := Low(pParams) to High(pParams) do
    FParams[I] := pParams[I];
  Result := Self;
end;

function TRESTfulClient.POST(const pBody: TJSONValue; const pBodyFree: Boolean): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPOST(FResource, FParams, pBody, pBodyFree)
    );
  Result := FRESTResponse;
end;

function TRESTfulClient.POST<TBodyType>(const pBody: TObjectList<TBodyType>; const pBodyFree: Boolean): TRESTfulResponse;
begin
  pBody.OwnsObjects := pBodyFree;

  FRESTResponse.SetRESTResponse(
    FRESTClient.doPOST(FResource, FParams, Mapper.ObjectListToJSONArray<TBodyType>(pBody, pBodyFree) as TJSONValue, True)
    );

  Result := FRESTResponse;
end;

function TRESTfulClient.POST(const pBody: string): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPOST(FResource, FParams, pBody)
    );
  Result := FRESTResponse;
end;

function TRESTfulClient.POST<TBodyType>(const pBody: TBodyType; const pBodyFree: Boolean): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPOST(FResource, FParams, Mapper.ObjectToJSONObject(pBody) as TJSONValue, True)
    );

  if pBodyFree then
    TObject(pBody).Free;

  Result := FRESTResponse;
end;

function TRESTfulClient.PUT(const pBody: TJSONValue; const pBodyFree: Boolean): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPUT(FResource, FParams, pBody, pBodyFree)
    );
  Result := FRESTResponse;
end;

function TRESTfulClient.PUT<TBodyType>(const pBody: TObjectList<TBodyType>; const pBodyFree: Boolean): TRESTfulResponse;
begin
  pBody.OwnsObjects := pBodyFree;

  FRESTResponse.SetRESTResponse(
    FRESTClient.doPUT(FResource, FParams, Mapper.ObjectListToJSONArray<TBodyType>(pBody, pBodyFree) as TJSONValue, True)
    );

  Result := FRESTResponse;
end;

function TRESTfulClient.PUT(const pBody: string): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPUT(FResource, FParams, pBody)
    );
  Result := FRESTResponse;
end;

function TRESTfulClient.PUT<TBodyType>(const pBody: TBodyType; const pBodyFree: Boolean): TRESTfulResponse;
begin
  FRESTResponse.SetRESTResponse(
    FRESTClient.doPUT(FResource, FParams, Mapper.ObjectToJSONObject(pBody) as TJSONValue, True)
    );

  if pBodyFree then
    TObject(pBody).Free;

  Result := FRESTResponse;
end;

function TRESTfulClient.ReadTimeOut(const pReadTimeOut: Cardinal): TRESTfulClient;
begin
  FRESTClient.ReadTimeOut := pReadTimeOut;
  Result := Self;
end;

function TRESTfulClient.Resource(const pResource: string): TRESTfulClient;
begin
  FResource := pResource;
  Result := Self;
end;

function TRESTfulClient.SSL(const pEnabled: Boolean): TRESTfulClient;
begin
  FRESTClient.SSL(pEnabled);
  Result := Self;
end;

{ TRESTfulResponse }

function TRESTfulResponse.AsJSONObject: TJSONObject;
begin
  Result := GetRESTResponse().BodyAsJsonObject;
end;

function TRESTfulResponse.AsJSONValue: TJSONValue;
begin
  Result := GetRESTResponse().BodyAsJsonValue;
end;

function TRESTfulResponse.AsObject<TResponseType>: TResponseType;
begin
  Result := Mapper.JSONObjectToObject<TResponseType>(
    GetRESTResponse().BodyAsJsonObject
    );
end;

function TRESTfulResponse.AsObjectList<TResponseType>: TObjectList<TResponseType>;
begin
  Result := Mapper.JSONArrayToObjectList<TResponseType>(
    (GetRESTResponse().BodyAsJsonValue as TJSONArray), False, True
    );
end;

function TRESTfulResponse.AsString: string;
begin
  Result := GetRESTResponse().BodyAsString;
end;

constructor TRESTfulResponse.Create;
begin
  FRESTResponse := nil;
end;

function TRESTfulResponse.GetRESTResponse: IRESTResponse;
begin
  if (FRESTResponse = nil) then
    raise ERESTClientException.Create('REST response is invalid!');
  Result := FRESTResponse;
end;

procedure TRESTfulResponse.SetRESTResponse(const pResponse: IRESTResponse);
begin
  FRESTResponse := pResponse;
end;

function TRESTfulResponse.StatusCode: Word;
begin
  Result := GetRESTResponse().ResponseCode;
end;

function TRESTfulResponse.StatusText: string;
begin
  Result := GetRESTResponse().ResponseText;
end;

end.
