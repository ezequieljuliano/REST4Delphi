unit REST4D.Adapter;

interface

uses
  System.SysUtils,
  REST4D.Client,
  MVCFramework.RESTAdapter;

type

  RESTResourceAttribute = MVCFramework.RESTAdapter.RESTResourceAttribute;
  BodyAttribute = MVCFramework.RESTAdapter.BodyAttribute;
  ParamAttribute = MVCFramework.RESTAdapter.ParamAttribute;
  HeadersAttribute = MVCFramework.RESTAdapter.HeadersAttribute;
  MappingAttribute = MVCFramework.RESTAdapter.MappingAttribute;

  TRESTAdapter<T: IInvokable> = class(MVCFramework.RESTAdapter.TRESTAdapter<T>)
  private
    FRESTfulClient: TRESTfulClient;
    FOwnsRESTfulClient: Boolean;
  public
    destructor Destroy; override;

    function Build(const pRESTfulClient: TRESTfulClient): T; overload;
    function Build(const pRESTfulClient: TRESTfulClient; const pOwnsRESTfulClient: Boolean): T; overload;
  end;

  IAsynchRequest = MVCFramework.RESTAdapter.IAsynchRequest;

  TAsynchRequest = MVCFramework.RESTAdapter.TAsynchRequest;

implementation

{ TRESTAdapter<T> }

function TRESTAdapter<T>.Build(const pRESTfulClient: TRESTfulClient; const pOwnsRESTfulClient: Boolean): T;
begin
  FRESTfulClient := pRESTfulClient;
  FOwnsRESTfulClient := pOwnsRESTfulClient;
  Result := Build(FRESTfulClient.DefaultClient)
end;

function TRESTAdapter<T>.Build(const pRESTfulClient: TRESTfulClient): T;
begin
  Result := Build(pRESTfulClient, False);
end;

destructor TRESTAdapter<T>.Destroy;
begin
  if FOwnsRESTfulClient then
    FreeAndNil(FRESTfulClient);
  inherited;
end;

end.
