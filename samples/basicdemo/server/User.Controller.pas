unit User.Controller;

interface

uses
  REST4D,
  REST4D.Server,
  System.Generics.Collections,
  System.SysUtils;

type

  [Path('/')]
  TUserController = class(TRESTController)
  public
    [Path('/hello')]
    [HTTPMethod([THTTPMethodType.httpGET])]
    procedure HelloWorld(ctx: TRESTWebContext);

    [Path('/user')]
    [HTTPMethod([THTTPMethodType.httpGET])]
    procedure GetUser(ctx: TRESTWebContext);

    [Path('/user/save')]
    [HTTPMethod([THTTPMethodType.httpPOST])]
    procedure PostUser(ctx: TRESTWebContext);

    [Path('/users')]
    [HTTPMethod([THTTPMethodType.httpGET])]
    procedure GetUsers(ctx: TRESTWebContext);

    [Path('/users/save')]
    [HTTPMethod([THTTPMethodType.httpPOST])]
    procedure PostUsers(ctx: TRESTWebContext);
  end;

implementation

uses
  User;

{ TAppController }

procedure TUserController.GetUser(ctx: TRESTWebContext);
var
  vUser: TUser;
begin
  vUser := TUser.Create;
  vUser.Cod := 1;
  vUser.Name := 'Ezequiel';
  vUser.Pass := '123';

  Render(vUser);
end;

procedure TUserController.GetUsers(ctx: TRESTWebContext);
var
  vUsers: TObjectList<TUser>;
  vUser: TUser;
  I: Integer;
begin
  vUsers := TObjectList<TUser>.Create(True);

  for I := 0 to 10 do
  begin
    vUser := TUser.Create;
    vUser.Cod := I;
    vUser.Name := 'Ezequiel ' + IntToStr(I);
    vUser.Pass := IntToStr(I);

    vUsers.Add(vUser);
  end;

  Render<TUser>(vUsers);
end;

procedure TUserController.HelloWorld(ctx: TRESTWebContext);
begin
  Render('Hello World called with GET');
end;

procedure TUserController.PostUser(ctx: TRESTWebContext);
var
  vUser: TUser;
begin
  vUser := ctx.Request.BodyAs<TUser>();

  if (vUser.Cod > 0) then
    Render('Sucess!')
  else
    Render('Error!');

  FreeAndNil(vUser);
end;

procedure TUserController.PostUsers(ctx: TRESTWebContext);
var
  vUsers: TObjectList<TUser>;
begin
  vUsers := ctx.Request.BodyAsListOf<TUser>();
  vUsers.OwnsObjects := True;

  if (vUsers.Count > 0) then
    Render('Sucess!')
  else
    Render('Error!');

  FreeAndNil(vUsers);
end;

end.
