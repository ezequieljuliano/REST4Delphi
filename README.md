# REST For Delphi #

The REST4Delphi is an API to facilitate the use of the project Delphi MVC Framework (https://code.google.com/p/delphimvcframework/).

With this API you can create servers that provide REST services. And consume REST services written in any programming language.

The REST4Delphi API was developed and tested in Delphi XE5.

## External Dependencies ##

The REST4Delphi is coupled to DMVCFramework. Therefore this dependence is included in the project within the "dependencies" folder.

- Delphi MVC Framework (https://code.google.com/p/delphimvcframework/);

## Using REST4Delphi API ##

Using this library will is very simple, you simply add the Search Path of your IDE or your project the following directories:

- REST4Delphi\src\

## How to Create a Server ##

First create your Controller:

       [MVCPath('/')]
       TAppController = class(TRESTController)
       public
         [MVCPath('/hello')]
         [MVCHTTPMethod([httpGET])]
         procedure HelloWorld(ctx: TWebContext);
       end;

Write a heritage REST4D.WebModule and implement the abstract method Initialize:

     TAppWebModule = class(TRESTWebModule)
     public
       procedure Initialize; override;
     end;

    procedure TAppWebModule.Initialize;
    begin
      inherited;
      RESTEngine.AddController(TAppController);
      RESTEngine.ServerName := 'Server1';
    end;

Add a public variable of type TComponentClass on your WebModule:

    var
      AppWebModuleClass: TComponentClass = TAppWebModule;

Now create your server:

    //Declare in your class or Unit   
	private
        FServerContainer: IRESTServerContainer;    

    procedure CreateServer;
	var
	  vServerInfo: IRESTServerInfo;
	begin
	  inherited;
	  vServerInfo := TRESTServerInfoFactory.GetInstance;
	  vServerInfo.ServerName := 'Server1';
	  vServerInfo.Port := 3000;
	  vServerInfo.MaxConnections := 1024;
	  vServerInfo.WebModuleClass := AppWebModuleClass;
	  vServerInfo.Authentication.AddUser('ezequiel', '123');
	
	  FServerContainer := TRESTServerContainerFactory.GetSingleton;
	  FServerContainer.CreateServer(vServerInfo);
	  FServerContainer.StartServers;
	end;

## Using the Client ##

It's very simple:

    var
      vRESTCli: TRESTfulClient;
    begin
      vRESTCli := TRESTfulClient.Create('localhost', 3000);
      try
         vRESTCli.Resource('/hello').Params([]);
         vRESTCli.Authorization('ezequiel', '123');
		 ShowMessage(vRESTCli.GET.AsString);    
      finally
         FreeAndNil(vRESTCli);
      end;
    end;

Analyze the unit tests and samples they will assist you.