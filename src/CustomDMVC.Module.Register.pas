(*
  Copyright 2013 Ezequiel Juliano Müller - ezequieljuliano@gmail.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

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
