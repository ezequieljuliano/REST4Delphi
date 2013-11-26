unit CustomDMVC.WebModuleBase;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  CustomDMVC;

type

  TCustomDMVCWebModuleBase = class(TWebModule)
  strict private
    FMVCEngine: TCustomMVCEngine;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Initialize(); virtual; abstract;

    property MVCEngine: TCustomMVCEngine read FMVCEngine;
  end;

implementation

{$R *.dfm}

procedure TCustomDMVCWebModuleBase.AfterConstruction;
begin
  inherited AfterConstruction;
  FMVCEngine := TCustomMVCEngine.Create(Self);
  FMVCEngine.ServerName := EmptyStr;
  Initialize();
end;

procedure TCustomDMVCWebModuleBase.BeforeDestruction;
begin
  FreeAndNil(FMVCEngine);
  inherited BeforeDestruction;
end;

end.
