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

program BasicDemoServer;

uses
  Vcl.Forms,
  Frm.Main in 'Frm.Main.pas' {FrmMain} ,
  REST4D.WebModule in '..\..\..\src\REST4D.WebModule.pas' {RESTWebModule: TWebModule} ,
  BasicDemo.AppWebModule in 'BasicDemo.AppWebModule.pas' {BasicDemoWebModule: TWebModule} ,
  User.Controller in 'User.Controller.pas',
  User in 'User.pas';

{$R *.res}


begin

  Application.Initialize;

  ReportMemoryLeaksOnShutdown := True;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;

end.
