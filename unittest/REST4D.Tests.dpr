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

program REST4D.Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  REST4D.Tests.UnitTest in 'REST4D.Tests.UnitTest.pas',
  REST4D.Server in '..\src\REST4D.Server.pas',
  REST4D in '..\src\REST4D.pas',
  REST4D.Client in '..\src\REST4D.Client.pas',
  REST4D.WebModule in '..\src\REST4D.WebModule.pas' {RESTWebModule: TWebModule},
  REST4D.Tests.AppWebModule in 'REST4D.Tests.AppWebModule.pas' {AppWebModule: TWebModule},
  REST4D.Tests.AppController in 'REST4D.Tests.AppController.pas',
  REST4D.Tests.TempWebModule in 'REST4D.Tests.TempWebModule.pas' {TempWebModule: TWebModule};

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
