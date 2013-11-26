unit App.Controller;

interface

uses
  MVCFramework,
  CustomDMVC;

type

  [MVCPath('/')]
  TAppController = class(TCustomMVCController)
  public
    [MVCPath('/hello')]
    [MVCHTTPMethod([httpGET])]
    procedure HelloWorld(ctx: TWebContext);
  end;

implementation

{ TAppController }

procedure TAppController.HelloWorld(ctx: TWebContext);
begin
  Render('Hello World!');
end;

end.
