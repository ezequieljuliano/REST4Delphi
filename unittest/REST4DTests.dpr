program REST4DTests;
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
  REST4D.Tests.TempWebModule in 'REST4D.Tests.TempWebModule.pas' {TempWebModule: TWebModule},
  REST4D.Adapter in '..\src\REST4D.Adapter.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
