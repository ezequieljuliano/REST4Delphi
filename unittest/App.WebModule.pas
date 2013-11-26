unit App.WebModule;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CustomDMVC.WebModuleBase;

type
  TAppWebModule = class(TCustomDMVCWebModuleBase)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  AppWebModuleClass: TComponentClass = TAppWebModule;

implementation

uses
  App.Controller;

{$R *.dfm}

{ TAppWebModule }

procedure TAppWebModule.Initialize;
begin
  inherited;
  MVCEngine.AddController(TAppController);
  MVCEngine.ServerName := 'Server1';
end;

end.
