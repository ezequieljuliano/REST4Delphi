# REST For Delphi #

The REST4Delphi is an API to facilitate the use of the project [Delphi MVC Framework](https://github.com/danieleteti/delphimvcframework).

With this API you can create servers that provide REST services and consume REST services written in any programming language.

The REST4Delphi API works with Delphi XE3 or higher and the client works on all platforms.

## External Dependencies ##

The REST4Delphi is coupled to DMVCFramework. Therefore this dependence is included in the project within the "dependencies" folder. You must put in the Path of his application or IDE the font directories of this dependence.

- [DMVCFramework (Delphi MVC Framework)](https://github.com/danieleteti/delphimvcframework);

## Samples ##

Within the project there are a few examples of API usage. In addition there are also some unit tests that can aid in the use of REST4Delphi.

## Using REST4Delphi API ##

Using this API will is very simple, you simply add the Search Path of your IDE or your project the following directories:

- REST4Delphi\src\

Then you must add to your project the WebModule, so that you can make to your heritage:

- REST4D.WebModule.pas

## REST4Delphi in 5 Minutes ##

Here is a step by step how to create a Delphi server application using the REST4D:

First, you must create your Controller that will provide the REST resources:

    uses
      REST4D,
      REST4D.Server,
      System.Generics.Collections,
      System.SysUtils;
    
    type
    
      [Path('/')]
      TUserController = class(TRESTController)
      public
         [Path('/hello')]
         [HTTPMethod([THTTPMethod.httpGET])]
         procedure HelloWorld(ctx: TRESTWebContext);
    
         [Path('/user')]
         [HTTPMethod([THTTPMethod.httpGET])]
         procedure GetUser(ctx: TRESTWebContext);
    
         [Path('/user/save')]
         [HTTPMethod([THTTPMethod.httpPOST])]
         procedure PostUser(ctx: TRESTWebContext);
    
         [Path('/users')]
         [HTTPMethod([THTTPMethod.httpGET])]
         procedure GetUsers(ctx: TRESTWebContext);
    
         [Path('/users/save')]
         [HTTPMethod([THTTPMethod.httpPOST])]
         procedure PostUsers(ctx: TRESTWebContext);
      end;

Now, you must inherit the REST4D.WebModule and create your own WebModule, implement the abstract method Initialize(const pRESTEngine: TRESTEngine) and SecurityLayer(out pRESTSecurity: IRESTSecurity) and add a public variable of type TComponentClass on your WebModule: 

    uses
      REST4D,
      REST4D.Server,
      REST4D.WebModule;
    
    type
    
      TBasicDemoWebModule = class(TRESTWebModule)
      private
          { Private declarations }
      public
          procedure Initialize(const pRESTEngine: TRESTEngine); override;
          procedure SecurityLayer(out pRESTSecurity: IRESTSecurity); override;
      end;
    
    var
       BasicDemoWebModuleClass: TComponentClass = TBasicDemoWebModule;
    
    implementation
    
    uses
      User.Controller;
    
    {$R *.dfm}
    
    { TAppWebModule }
    
    procedure TBasicDemoWebModule.Initialize;
    begin
      inherited;
      pRESTEngine.AddController(TUserController);
    end;
    
    procedure TBasicDemoWebModule.SecurityLayer(out pRESTSecurity: IRESTSecurity);
    begin
      inherited;
      pRESTSecurity := RESTServerDefault.Container
         .FindServerByName('ServerBasicDemo').Info.Security;
    end;

Now create your server using the container:

    uses
      REST4D, REST4D.Server,
      BasicDemo.AppWebModule;
    
    procedure CreateServer;
    var
      vServerInfo: IRESTServerInfo;
      vOnAuthentication: TRESTAuthenticationDelegate;
    begin
      vServerInfo := TRESTServerInfoFactory.Build;
      vServerInfo.ServerName := 'ServerBasicDemo';
      vServerInfo.Port := 3000;
      vServerInfo.MaxConnections := 1024;
      vServerInfo.WebModuleClass := BasicDemoWebModuleClass;
      
      vOnAuthentication := procedure(const pUserName, pPassword: string;
          pUserRoles: TList<string>; var pIsValid: Boolean)
        begin
           pIsValid := pUserName.Equals('ezequiel') and pPassword.Equals('123');
        end;

      vServerInfo.Security := TRESTDefaultSecurity.Create(vOnAuthentication, nil);
    
      RESTServer.Container.CreateServer(vServerInfo);
      RESTServer.Container.StartServers;
    end;

## Using the TRESTfulClient ##

It's very simple:
 
    uses
       REST4D.Client, REST4D;
    
    var
       vRESTfulClient: TRESTfulClient;
       vResp: TRESTfulResponse;
    begin
       vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
       try
         vRESTfulClient.Resource('/user').Params([]);
         vRESTfulClient.Authorization('ezequiel', '123');    
         vResp := vRESTfulClient.GET;   
         ShowMessage(vResp.AsString);
       finally
         FreeAndNil(vRESTfulClient);
       end;
    end;

## Using the TRESTAdapter ##

The Adapter is a way to create a mapped interface with your REST resources that exist on the server. Thus, the Client you direct calls the methods of the interface.

First, create and map the resource to be consumed:
    
    uses
      User,
      System.Generics.Collections,
      REST4D.Mapping,      
      REST4D,
      REST4D.Adapter;
    
    type
    
      IUserResource = interface(IInvokable)
        ['{BF864FFF-7EB6-4A07-812E-EAC80F7AE0C9}']
        [RESTResource(THTTPMethod.httpGET, '/hello')]
        function HelloWorld(): string;
    
        [RESTResource(THTTPMethod.httpGET, '/user')]
        function GetUser(): TUser;
    
        [RESTResource(THTTPMethod.httpPOST, '/user/save')]
        procedure PostUser([Body] pBody: TUser);
    
        [RESTResource(THTTPMethod.httpGET, '/users')]
        [MapperListOf(TUser)]
        function GetUsers(): TObjectList<TUser>;
    
        [RESTResource(THTTPMethod.httpPOST, '/users/save')]
        procedure PostUsers([Body] pBody: TObjectList<TUser>);
      end;

Now, initialize the resource and use it wherever you need:

    uses
       User.Resource;
    
    //In class or Form ...
    private
       FUserResource: IUserResource;
    
    procedure Initialize;
    var
       vRESTfulClient: TRESTfulClient;
       vRESTAdapter: TRESTAdapter<IUserResource>;
    begin
       vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
       vRESTfulClient.Authorization('ezequiel', '123');
       vRESTAdapter := TRESTAdapter<IUserResource>.Create;
       vRESTAdapter.Build(vRESTfulClient, True);
       FUserResource := vRESTAdapter.ResourcesService;
    end;

    procedure ShowUsers;
    var
       vUsers: TObjectList<TUser>;
       I: Integer;
    begin
       vUsers := FUserResource.GetUsers;
       try
         vUsers.OwnsObjects := True;
         for I := 0 to vUsers.Count - 1 do
           ShowMessage(vUsers.Items[I].Name);
       finally
         FreeAndNil(vUsers);
       end;
    end;