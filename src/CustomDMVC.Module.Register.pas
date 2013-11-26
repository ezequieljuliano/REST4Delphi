unit CustomDMVC.Module.Register;

interface

implementation

uses
  Spring.Container,
  CustomDMVC,
  CustomDMVC.Impl;

procedure RegisterClasses();
begin
  GlobalContainer.RegisterType<TCustomMVCUserAuthenticate>.Implements<ICustomMVCUserAuthenticate>.AsTransient;
  GlobalContainer.RegisterType<TCustomMVCAuthentication>.Implements<ICustomMVCAuthentication>.AsTransient;
  GlobalContainer.RegisterType<TCustomMVCServerInfo>.Implements<ICustomMVCServerInfo>.AsTransient;
  GlobalContainer.RegisterType<TCustomMVCServer>.Implements<ICustomMVCServer>.AsTransient;
  GlobalContainer.RegisterType<TCustomMVCServerManager>.Implements<ICustomMVCServerManager>.AsSingleton;

  GlobalContainer.Build;
end;

initialization

RegisterClasses();

end.
