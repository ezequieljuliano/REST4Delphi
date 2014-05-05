unit REST4D.Tests.AppWebModule;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  REST4D.WebModule;

type

  TAppWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  AppWebModuleClass: TComponentClass = TAppWebModule;

implementation

uses
  REST4D.Tests.AppController;

{$R *.dfm}

{ TAppWebModule }

procedure TAppWebModule.Initialize;
begin
  inherited;
  RESTEngine.AddController(TAppController);
  RESTEngine.ServerName := 'Server1';
end;

end.
