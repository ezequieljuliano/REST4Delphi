unit Frm.Main.Client;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections;

type

  TFrmMainClient = class(TForm)
    Button1: TButton;
    MemResp: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMainClient: TFrmMainClient;

implementation

uses
  REST4D.Client, REST4D, User;

{$R *.dfm}


procedure TFrmMainClient.Button1Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/user').Params([]);
    vRESTfulClient.Authentication('ezequiel', '123');

    vResp := vRESTfulClient.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

procedure TFrmMainClient.Button2Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/users').Params([]);
    vRESTfulClient.Authentication('ezequiel', '123');

    vResp := vRESTfulClient.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

procedure TFrmMainClient.Button3Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/hello').Params([]);
    vRESTfulClient.Authentication('ezequiel', '123');

    vResp := vRESTfulClient.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

procedure TFrmMainClient.Button4Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/user/save').Params([]);
    vRESTfulClient.Authentication('ezequiel', '123');

    vUser := TUser.Create;
    vUser.Cod := 1;
    vUser.Name := 'Ezequiel';
    vUser.Pass := '123';

    vResp := vRESTfulClient.POST<TUser>(vUser);

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

procedure TFrmMainClient.Button5Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vUsers: TObjectList<TUser>;
  vResp: TRESTfulResponse;
  I: Integer;
  vUser: TUser;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/users/save').Params([]);
    vRESTfulClient.Authentication('ezequiel', '123');

    vUsers := TObjectList<TUser>.Create(True);

    for I := 0 to 10 do
    begin
      vUser := TUser.Create;
      vUser.Cod := I;
      vUser.Name := 'Ezequiel ˆ¸·‡Á„ı∫s ' + IntToStr(I);
      vUser.Pass := IntToStr(I);

      vUsers.Add(vUser);
    end;

    vResp := vRESTfulClient.POST<TUser>(vUsers);

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

procedure TFrmMainClient.Button6Click(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  try
    vRESTfulClient.Resource('/user').Params([]);
    vRESTfulClient.Authentication('123', '123');

    vResp := vRESTfulClient.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRESTfulClient);
  end;
end;

end.
