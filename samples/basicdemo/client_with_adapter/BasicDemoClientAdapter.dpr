program BasicDemoClientAdapter;

uses
  Vcl.Forms,
  Frm.Main.Client.Adapter in 'Frm.Main.Client.Adapter.pas' {MainClientAdapter} ,
  User in '..\server\User.pas',
  User.Resource in 'User.Resource.pas';

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainClientAdapter, MainClientAdapter);
  Application.Run;

end.
