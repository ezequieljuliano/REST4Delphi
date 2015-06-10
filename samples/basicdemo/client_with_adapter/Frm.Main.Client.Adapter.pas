unit Frm.Main.Client.Adapter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, User.Resource;

type

  TMainClientAdapter = class(TForm)
    Button1: TButton;
    MemResp: TMemo;
    Button2: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FUserResource: IUserResource;
  public
    { Public declarations }
  end;

var
  MainClientAdapter: TMainClientAdapter;

implementation

uses
  REST4D.Adapter, REST4D.Client, REST4D, User, System.Generics.Collections;

{$R *.dfm}

procedure TMainClientAdapter.Button1Click(Sender: TObject);
var
  vUser: TUser;
begin
  vUser := FUserResource.GetUser;
  try
    MemResp.Lines.Add(vUser.Name);
  finally
    FreeAndNil(vUser);
  end;
end;

procedure TMainClientAdapter.Button2Click(Sender: TObject);
var
  vUsers: TObjectList<TUser>;
  I: Integer;
begin
  vUsers := FUserResource.GetUsers;
  try
    vUsers.OwnsObjects := True;
    for I := 0 to vUsers.Count - 1 do
      MemResp.Lines.Add(vUsers.Items[I].Name);
  finally
    FreeAndNil(vUsers);
  end;
end;

procedure TMainClientAdapter.Button3Click(Sender: TObject);
begin
  MemResp.Lines.Add(FUserResource.HelloWorld);
end;

procedure TMainClientAdapter.FormCreate(Sender: TObject);
var
  vRESTfulClient: TRESTfulClient;
  vRESTAdapter: TRESTAdapter<IUserResource>;
begin
  vRESTfulClient := TRESTfulClient.Create('localhost', 3000);
  vRESTfulClient.Authentication('ezequiel', '123');
  vRESTAdapter := TRESTAdapter<IUserResource>.Create;
  vRESTAdapter.Build(vRESTfulClient, True);
  FUserResource := vRESTAdapter.ResourcesService;
end;

end.
