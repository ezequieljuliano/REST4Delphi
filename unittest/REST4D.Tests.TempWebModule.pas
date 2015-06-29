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
    { Public declarations }
  end;

var
  TempWebModuleClass: TComponentClass = TTempWebModule;

implementation

{$R *.dfm}

end.
