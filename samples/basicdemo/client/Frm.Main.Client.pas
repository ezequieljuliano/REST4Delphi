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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
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
  vRestCli: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/user').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vResp := vRestCli.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TFrmMainClient.Button2Click(Sender: TObject);
var
  vRestCli: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/users').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vResp := vRestCli.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TFrmMainClient.Button3Click(Sender: TObject);
var
  vRestCli: TRESTfulClient;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/hello').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vResp := vRestCli.GET;

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TFrmMainClient.Button4Click(Sender: TObject);
var
  vRestCli: TRESTfulClient;
  vUser: TUser;
  vResp: TRESTfulResponse;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/user/save').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUser := TUser.Create;
    vUser.Cod := 1;
    vUser.Name := 'Ezequiel';
    vUser.Pass := '123';

    vResp := vRestCli.POST<TUser>(vUser);

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRestCli);
  end;
end;

procedure TFrmMainClient.Button5Click(Sender: TObject);
var
  vRestCli: TRESTfulClient;
  vUsers: TObjectList<TUser>;
  vResp: TRESTfulResponse;
  I: Integer;
  vUser: TUser;
begin
  vRestCli := TRESTfulClient.Create('localhost', 3000);
  try
    vRestCli.Resource('/users/save').Params([]);
    vRestCli.Authorization('ezequiel', '123');

    vUsers := TObjectList<TUser>.Create(True);

    for I := 0 to 10 do
    begin
      vUser := TUser.Create;
      vUser.Cod := I;
      vUser.Name := 'Ezequiel ˆ¸·‡Á„ı∫s ' + IntToStr(I);
      vUser.Pass := IntToStr(I);

      vUsers.Add(vUser);
    end;

    vResp := vRestCli.POST<TUser>(vUsers);

    MemResp.Lines.Add(vResp.AsString);
  finally
    FreeAndNil(vRestCli);
  end;
end;

end.
