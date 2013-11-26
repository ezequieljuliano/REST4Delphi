# Custom Delphi MVC Framework #

The CustomDMVCFramework is an API to facilitate the use of the project DelphiMVCFramework (https://code.google.com/p/delphimvcframework/).

The CustomDMVCFramework API was developed and tested in Delphi XE4.

## External Dependencies ##
To use CustomDMVCFramework you must install in your IDE the following projects:

- DelphiMVCFramework (https://code.google.com/p/delphimvcframework/);
- Delphi Spring Framework (https://code.google.com/p/delphi-spring-framework/);

## How to Use ##

First create your Controller:

     [MVCPath('/')]
     TAppController = class(TCustomMVCController)
     public
       [MVCPath('/hello')]
       [MVCHTTPMethod([httpGET])]
       procedure HelloWorld(ctx: TWebContext);
     end;

Write a heritage CustomDMVC.WebModuleBase and implement the abstract method Initialize:

     TAppWebModule = class(TCustomDMVCWebModuleBase)
     public
       procedure Initialize; override;
     end;

    procedure TAppWebModule.Initialize;
    begin
      inherited;
      MVCEngine.AddController(TAppController);
      MVCEngine.ServerName := 'Server1';
    end;

Add a public variable of type TComponentClass on your WebModule:

    var
      AppWebModuleClass: TComponentClass = TAppWebModule;

Now create your server:

    procedure CreateServer;
    var
      vServerInfo: ICustomMVCServerInfo;
    begin
      inherited;
      vServerInfo := TCustomMVC.NewServerInfo;
      vServerInfo.ServerName := 'Server1';
      vServerInfo.Port := 3000;
      vServerInfo.MaxConnections := 100;
      vServerInfo.WebModuleClass := AppWebModuleClass;
      vServerInfo.Authentication.AddUser('ezequiel', '123');
    
      TCustomMVC.ServerManager.CreateServer(vServerInfo);
      TCustomMVC.ServerManager.StartServers();
    end;

Add to your .dpr registration of classes for working with dependency injection, the Unit is responsible for this CustomDMVC.Module.Register.pas:

    uses
      DUnitTestRunner,
      CustomDMVC in '..\src\CustomDMVC.pas',
      CustomDMVC.Impl in '..\src\CustomDMVC.Impl.pas',
      CustomDMVC.Codification in '..\src\CustomDMVC.Codification.pas',
      CustomDMVC.WebModuleBase in '..\src\CustomDMVC.WebModuleBase.pas' {CustomDMVCWebModuleBase: TWebModule} ,
      CustomDMVC.UnitTest in 'CustomDMVC.UnitTest.pas',
      App.WebModule in 'App.WebModule.pas' {AppWebModule: TWebModule} ,
      App.Controller in 'App.Controller.pas',
      CustomDMVC.Module.Register in '..\src\CustomDMVC.Module.Register.pas';

Analyze the unit tests they will assist you.

