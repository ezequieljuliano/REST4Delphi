unit User.Resource;

interface

uses
  User,
  System.Generics.Collections,
  REST4D,
  REST4D.Mapping,
  REST4D.Adapter;

type

  IUserResource = interface(IInvokable)
    ['{BF864FFF-7EB6-4A07-812E-EAC80F7AE0C9}']
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

implementation

end.
