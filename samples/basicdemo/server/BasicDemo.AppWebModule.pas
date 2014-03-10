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

unit BasicDemo.AppWebModule;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  REST4D.WebModule;

type

  TBasicDemoWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  BasicDemoWebModuleClass: TComponentClass = TBasicDemoWebModule;

implementation

uses
  User.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TBasicDemoWebModule.Initialize;
begin
  inherited;
  RESTEngine.AddController(TUserController);
  RESTEngine.ServerName := 'ServerBasicDemo';
end;

end.
