program CustomDMVCFramework;
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
  CustomDMVC in '..\src\CustomDMVC.pas',
  CustomDMVC.Impl in '..\src\CustomDMVC.Impl.pas',
  CustomDMVC.Codification in '..\src\CustomDMVC.Codification.pas',
  CustomDMVC.WebModuleBase in '..\src\CustomDMVC.WebModuleBase.pas' {CustomDMVCWebModuleBase: TWebModule},
  CustomDMVC.Module.Register in '..\src\CustomDMVC.Module.Register.pas',
  CustomDMVC.UnitTest in 'CustomDMVC.UnitTest.pas',
  App.WebModule in 'App.WebModule.pas' {AppWebModule: TWebModule},
  App.Controller in 'App.Controller.pas';

{ R *.RES }

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
