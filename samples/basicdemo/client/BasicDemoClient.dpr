program BasicDemoClient;

uses
  Vcl.Forms,
  Frm.Main.Client in 'Frm.Main.Client.pas' {FrmMainClient} ,
  User in '..\server\User.pas';

{$R *.res}


begin

  Application.Initialize;

  ReportMemoryLeaksOnShutdown := True;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMainClient, FrmMainClient);
  Application.Run;

end.
