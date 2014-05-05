unit REST4D.Tests.TempWebModule;

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

  TTempWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize; override;
  end;

var
  TempWebModuleClass: TComponentClass = TTempWebModule;

implementation

{$R *.dfm}

{ TTempWebModule }

procedure TTempWebModule.Initialize;
begin
  inherited;
  RESTEngine.ServerName := 'ServerTemp';
end;

end.
