unit REST4D.Tests.TempWebModule;

interface

uses
  System.SysUtils,
  System.Classes,
  REST4D,
  REST4D.Server,
  REST4D.WebModule;

type

  TTempWebModule = class(TRESTWebModule)
  private
    { Private declarations }
  public
    procedure Initialize(const pRESTEngine: TRESTEngine); override;
    procedure SecurityLayer(out pRESTSecurity: IRESTSecurity); override;
  end;

var
  TempWebModuleClass: TComponentClass = TTempWebModule;

implementation

{$R *.dfm}

{ TTempWebModule }

procedure TTempWebModule.Initialize(const pRESTEngine: TRESTEngine);
begin
  inherited;

end;

procedure TTempWebModule.SecurityLayer(out pRESTSecurity: IRESTSecurity);
begin
  inherited;
  pRESTSecurity := nil;
end;

end.
