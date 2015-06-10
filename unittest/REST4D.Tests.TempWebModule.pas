unit REST4D.Tests.TempWebModule;

interface

uses
  System.SysUtils,
  System.Classes,
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
