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

unit App.WebModule;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CustomDMVC.WebModuleBase;

type
  TAppWebModule = class(TCustomDMVCWebModuleBase)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  AppWebModuleClass: TComponentClass = TAppWebModule;

implementation

uses
  App.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TAppWebModule.Initialize;
begin
  inherited;
  MVCEngine.AddController(TAppController);
  MVCEngine.ServerName := 'Server1';
end;

end.
