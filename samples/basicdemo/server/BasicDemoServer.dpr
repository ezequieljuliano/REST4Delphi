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
