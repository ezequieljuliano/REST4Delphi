(*
  Copyright 2014 Ezequiel Juliano Müller | Microsys Sistemas Ltda

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

unit REST4D.WebModule;

interface

uses
  REST4D,
  REST4D.Server,
  System.SysUtils,
  System.Classes,
  Web.HTTPApp;

type

  TRESTWebModule = class(TWebModule)
  strict private
    FRESTEngine: TRESTEngine;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Initialize(); virtual; abstract;

    property RESTEngine: TRESTEngine read FRESTEngine;
  end;

implementation

{$R *.dfm}

procedure TRESTWebModule.AfterConstruction;
begin
  inherited AfterConstruction;
  FRESTEngine := TRESTEngine.Create(Self);
  FRESTEngine.ServerName := EmptyStr;
  Initialize();
end;

procedure TRESTWebModule.BeforeDestruction;
begin
  FreeAndNil(FRESTEngine);
  inherited BeforeDestruction;
end;

end.
