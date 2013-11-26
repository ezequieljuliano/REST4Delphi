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

unit CustomDMVC.UnitTest;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  CustomDMVC,
  MVCFramework.RESTClient;

type

  TTestCustomDMVC = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestUserAndPass();
    procedure TestApiKey();
  end;

implementation

uses
  App.WebModule;

{ TTestCustomDMVC }

procedure TTestCustomDMVC.SetUp;
var
  vServerInfo: ICustomMVCServerInfo;
begin
  inherited;
  vServerInfo := TCustomMVC.NewServerInfo;
  vServerInfo.ServerName := 'Server1';
  vServerInfo.Port := 3000;
  vServerInfo.MaxConnections := 1024;
  vServerInfo.WebModuleClass := AppWebModuleClass;
  vServerInfo.Authentication.AddUser('ezequiel', '123');

  TCustomMVC.ServerManager.CreateServer(vServerInfo);
  TCustomMVC.ServerManager.StartServers();
end;

procedure TTestCustomDMVC.TearDown;
begin
  inherited;

end;

procedure TTestCustomDMVC.TestApiKey;
var
  vRESTClient: TRESTClient;
  vResponse: IRESTResponse;
begin
  vRESTClient := TRESTClient.Create('localhost', 3000);
  try
    vRESTClient.RequestHeaders.Add('ApiKey=8d75ebf9dd230e87d35aa305387c6b074ce475b9');
    vResponse := vRESTClient.doGET('/hello', []);

    CheckTrue((vResponse.BodyAsString = '"Hello World!"'));
  finally
    FreeAndNil(vRESTClient);
  end;
end;

procedure TTestCustomDMVC.TestUserAndPass;
var
  vRESTClient: TRESTClient;
  vResponse: IRESTResponse;
begin
  vRESTClient := TRESTClient.Create('localhost', 3000);
  try
    vRESTClient.RequestHeaders.Add('Authorization=Basic ZXplcXVpZWw6MTIz');
    vResponse := vRESTClient.doGET('/hello', []);

    CheckTrue((vResponse.BodyAsString = '"Hello World!"'));
  finally
    FreeAndNil(vRESTClient);
  end;
end;

initialization

RegisterTest(TTestCustomDMVC.Suite);

end.
