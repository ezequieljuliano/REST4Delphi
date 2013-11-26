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

unit CustomDMVC.WebModuleBase;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  CustomDMVC;

type

  TCustomDMVCWebModuleBase = class(TWebModule)
  strict private
    FMVCEngine: TCustomMVCEngine;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Initialize(); virtual; abstract;

    property MVCEngine: TCustomMVCEngine read FMVCEngine;
  end;

implementation

{$R *.dfm}

procedure TCustomDMVCWebModuleBase.AfterConstruction;
begin
  inherited AfterConstruction;
  FMVCEngine := TCustomMVCEngine.Create(Self);
  FMVCEngine.ServerName := EmptyStr;
  Initialize();
end;

procedure TCustomDMVCWebModuleBase.BeforeDestruction;
begin
  FreeAndNil(FMVCEngine);
  inherited BeforeDestruction;
end;

end.
