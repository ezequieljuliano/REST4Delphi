unit User.Resource;

interface

uses
  User,
  ObjectsMappers,
  System.Generics.Collections,
  REST4D,
  REST4D.Adapter;

type

  IUserResource = interface(IInvokable)
    ['{BF864FFF-7EB6-4A07-812E-EAC80F7AE0C9}']
    [RESTResource(THTTPMethodType.httpGET, '/hello')]
    function HelloWorld(): string;

    [RESTResource(THTTPMethodType.httpGET, '/user')]
    function GetUser(): TUser;

    [RESTResource(THTTPMethodType.httpPOST, '/user/save')]
    procedure PostUser([Body] pBody: TUser);

    [RESTResource(THTTPMethodType.httpGET, '/users')]
    [MapperListOf(TUser)]
    function GetUsers(): TObjectList<TUser>;

    [RESTResource(THTTPMethodType.httpPOST, '/users/save')]
    procedure PostUsers([Body] pBody: TObjectList<TUser>);
  end;

implementation

end.
