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

unit User.Controller;

interface

uses
  REST4D,
  REST4D.Server,
  MVCFramework,
  System.Generics.Collections,
  System.SysUtils;

type

  [MVCPath('/')]
  TUserController = class(TRESTController)
  public
    [MVCPath('/hello')]
    [MVCHTTPMethod([httpGET])]
    procedure HelloWorld(ctx: TWebContext);

    [MVCPath('/user')]
    [MVCHTTPMethod([httpGET])]
    procedure GetUser(ctx: TWebContext);

    [MVCPath('/user/save')]
    [MVCHTTPMethod([httpPOST])]
    procedure PostUser(ctx: TWebContext);

    [MVCPath('/users')]
    [MVCHTTPMethod([httpGET])]
    procedure GetUsers(ctx: TWebContext);

    [MVCPath('/users/save')]
    [MVCHTTPMethod([httpPOST])]
    procedure PostUsers(ctx: TWebContext);
  end;

implementation

uses
  User;

{ TAppController }

procedure TUserController.GetUser(ctx: TWebContext);
var
  vUser: TUser;
begin
  vUser := TUser.Create;
  vUser.Cod := 1;
  vUser.Name := 'Ezequiel';
  vUser.Pass := '123';

  Render(vUser);
end;

procedure TUserController.GetUsers(ctx: TWebContext);
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

procedure TUserController.HelloWorld(ctx: TWebContext);
begin
  Render('Hello World called with GET');
end;

procedure TUserController.PostUser(ctx: TWebContext);
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

procedure TUserController.PostUsers(ctx: TWebContext);
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
