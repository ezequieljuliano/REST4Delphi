unit Iocp.PacketSocket;

{$define __LOGIC_THREAD_POOL__}

interface

uses
  Windows, Classes, SysUtils, Math, Iocp.Winsock2, Iocp.TcpSocket, Iocp.ThreadPool, Iocp.Logger;

type
  TIocpHeader = record
    HeaderCrc32, DataCrc32: LongWord;
    Tick: LongWord;
    DataSize: Integer;
  end;

  PIocpPacket = ^TIocpPacket;
  TIocpPacket = record
    Header: TIocpHeader;
    Data: Pointer;
  end;

  TIocpPacketConnection = class(TIocpSocketConnection)
  private
    FRecvPacketBytes: Integer;
    FRecvPacket: PIocpPacket;

    function CalcCrc32(const Buf; const BufSize: Integer): LongWord; overload;
    function CalcCrc32(Stream: TStream): LongWord; overload;
    function CalcHeaderCrc(const Header: TIocpHeader): LongWord;
    function MakeHeader(Buf: Pointer; Len: Integer): TIocpHeader; overload;
    function MakeHeader(Stream: TStream): TIocpHeader; overload;
    function CheckHeaderCrc(const Header: TIocpHeader): Boolean;
    function CheckDataCrc(const Packet: TIocpPacket): Boolean;
  protected
    procedure Initialize; override;
  public
    function Send(Buf: Pointer; Size: Integer): Integer; overload; override;
    function Send(Stream: TStream): Integer; overload; override;
  end;

  {
    *** Iocp逻辑(业务处理)请求对象 ***
  }
  TIocpPacketRequest = class(TIocpThreadRequest)
  private
    Client: TIocpPacketConnection;
    Packet: PIocpPacket;
  protected
    procedure Execute; override;
  public
    constructor Create(Client: TIocpPacketConnection; Packet: PIocpPacket);
  end;

  TIocpPacketEvent = procedure(Sender: TObject; Client: TIocpPacketConnection; const Packet: TIocpPacket) of object;
  TIocpPacketSocket = class(TIocpTcpSocket)
  private
    {$ifdef __LOGIC_THREAD_POOL__}
    FJobThreadPool: TIocpThreadPool;
    {$endif}
    FCrcEnabled: Boolean;
    FOnPacketRecv: TIocpPacketEvent;
    FOnPacketHeaderCrcError: TIocpPacketEvent;
    FOnPacketDataCrcError: TIocpPacketEvent;
  protected
    {$ifdef __LOGIC_THREAD_POOL__}
    procedure StartupWorkers; override;
    procedure ShutdownWorkers; override;
    {$endif}

    procedure TriggerClientRecvData(Client: TIocpSocketConnection; Buf: Pointer; Len: Integer); override;
  protected
    procedure TriggerPacketRecv(Client: TIocpPacketConnection; const Packet: TIocpPacket); virtual;
    procedure TriggerPacketHeaderCrcError(Client: TIocpPacketConnection; const Packet: TIocpPacket); virtual;
    procedure TriggerPacketDataCrcError(Client: TIocpPacketConnection; const Packet: TIocpPacket); virtual;
  public
    constructor Create(AOwner: TComponent); overload; override;
  published
    property CrcEnabled: Boolean read FCrcEnabled write FCrcEnabled default True;
    property OnPacketRecv: TIocpPacketEvent read FOnPacketRecv write FOnPacketRecv;
    property OnPacketHeaderCrcError: TIocpPacketEvent read FOnPacketHeaderCrcError write FOnPacketHeaderCrcError;
    property OnPacketDataCrcError: TIocpPacketEvent read FOnPacketDataCrcError write FOnPacketDataCrcError;
  end;

  TIocpPacketServer = class(TIocpPacketSocket)
  private
    FAddr: string;
    FPort: Word;
    FListened: Boolean;
    FInitAcceptNum: Integer;
    FStartTick: DWORD;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Start: Boolean;
    function Stop: Boolean;
  published
    property Addr: string read FAddr write FAddr;
    property Port: Word read FPort write FPort;
    property InitAcceptNum: Integer read FInitAcceptNum write FInitAcceptNum default INIT_ACCEPTEX_NUM;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Iocp', [TIocpPacketSocket, TIocpPacketServer]);
end;

{ TIocpPacketConnection }

procedure TIocpPacketConnection.Initialize;
begin
  inherited Initialize;
  FRecvPacketBytes := 0;
  ZeroMemory(@FRecvPacket, SizeOf(FRecvPacket));
end;

function TIocpPacketConnection.CalcCrc32(const Buf; const BufSize: Integer): LongWord;
var
  I: Integer;
  P: PByte;
begin
  Result := 0;
  P := @Buf;
  for I := 1 to BufSize do
  begin
    Inc(Result, P^);
    Inc(P);
  end;
end;

function TIocpPacketConnection.CalcCrc32(Stream: TStream): LongWord;
var
  B: Byte;
begin
  Result := 0;
  Stream.Position := 0;
  while (Stream.Read(B, SizeOf(Byte)) > 0) do
    Inc(Result, B)
end;

function TIocpPacketConnection.CalcHeaderCrc(const Header: TIocpHeader): LongWord;
begin
  Result := CalcCrc32((PAnsiChar(@Header) + SizeOf(Header.HeaderCrc32))^, SizeOf(Header) - SizeOf(Header.HeaderCrc32));
end;

function TIocpPacketConnection.MakeHeader(Stream: TStream): TIocpHeader;
begin
  Result.DataCrc32 := CalcCrc32(Stream);
  Result.Tick := GetTickCount;
  Result.DataSize := Stream.Size;
  Result.HeaderCrc32 := CalcHeaderCrc(Result);
end;

function TIocpPacketConnection.MakeHeader(Buf: Pointer;
  Len: Integer): TIocpHeader;
begin
  Result.DataCrc32 := CalcCrc32(Buf^, Len);
  Result.Tick := GetTickCount;
  Result.DataSize := Len;
  Result.HeaderCrc32 := CalcHeaderCrc(Result);
end;

function TIocpPacketConnection.CheckHeaderCrc(const Header: TIocpHeader): Boolean;
begin
  Result := (CalcHeaderCrc(Header) = Header.HeaderCrc32);
end;

function TIocpPacketConnection.CheckDataCrc(const Packet: TIocpPacket): Boolean;
begin
  Result := (CalcCrc32(Packet.Data^, Packet.Header.DataSize) = Packet.Header.DataCrc32);
end;

function TIocpPacketConnection.Send(Buf: Pointer; Size: Integer): Integer;
var
  Header: TIocpHeader;
begin
  Header := MakeHeader(Buf, Size);
  if (inherited Send(@Header, SizeOf(Header)) < 0) then Exit(-1);
  if (inherited Send(Buf, Size) < 0) then Exit(-2);

  Result := Size;
end;

function TIocpPacketConnection.Send(Stream: TStream): Integer;
var
  Header: TIocpHeader;
begin
  Header := MakeHeader(Stream);
  if (inherited Send(@Header, SizeOf(Header)) < 0) then Exit(-1);
  if (inherited Send(Stream) < 0) then Exit(-2);

  Result := Stream.Size;
end;

{ TIocpPacketRequest }

constructor TIocpPacketRequest.Create(Client: TIocpPacketConnection;
  Packet: PIocpPacket);
begin
  Self.Client := Client;
  Self.Packet := Packet;
end;

procedure TIocpPacketRequest.Execute;
begin
  if (Packet = nil) then Exit;
  TIocpPacketSocket(Client.Owner).TriggerPacketRecv(Client, Packet^);
  Client.Release;
  if (Packet.Data <> nil) then
    FreeMem(Packet.Data);
  Dispose(Packet);
end;

{ TIocpPacketSocket }

constructor TIocpPacketSocket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ConnectionClass := TIocpPacketConnection;
  FCrcEnabled := True;
end;

{$ifdef __LOGIC_THREAD_POOL__}
procedure TIocpPacketSocket.StartupWorkers;
begin
  if not Assigned(FJobThreadPool) then
    FJobThreadPool := TIocpThreadPool.Create;

  inherited StartupWorkers;
end;

procedure TIocpPacketSocket.ShutdownWorkers;
begin
  inherited ShutdownWorkers;

  if Assigned(FJobThreadPool) then
  begin
    FJobThreadPool.Shutdown;
    FreeAndNil(FJobThreadPool);
  end;
end;
{$endif}

procedure TIocpPacketSocket.TriggerClientRecvData(Client: TIocpSocketConnection;
  Buf: Pointer; Len: Integer);
var
  p: PByte;
  r: Integer;
begin
  with TIocpPacketConnection(Client) do
  begin
    if (FRecvPacket = nil) then
    begin
      New(FRecvPacket);
      ZeroMemory(FRecvPacket, SizeOf(TIocpPacket));
    end;

    // 包头
    if (FRecvPacketBytes < SizeOf(TIocpHeader)) then
    begin
      p := @FRecvPacket.Header;
      Inc(p, FRecvPacketBytes);
      r := Min(SizeOf(TIocpHeader) - FRecvPacketBytes, Len);
      CopyMemory(p, Buf, r);
      Inc(FRecvPacketBytes, r);

      // 如果包头和一部分包体一起接收到
      // 递归一下将剩余的部分写到FRecvPacket.Data中
      if (Len > r) then
      begin
        p := Buf;
        Inc(p, r);
        TriggerClientRecvData(Client, p, Len - r);
      end;
    end else
    // 包体
    begin
      // 不管是否开启CrcEnabled开关，都必须校验包头
      // 这才能保证收到的是有效包，而不是不可靠来源发来的垃圾包
      if not CheckHeaderCrc(FRecvPacket.Header) then
      begin
        TriggerPacketHeaderCrcError(TIocpPacketConnection(Client), FRecvPacket^);
        Client.Disconnect;
        Exit;
      end;

      if (FRecvPacket.Data = nil) then
      begin
        try
          GetMem(FRecvPacket.Data, FRecvPacket.Header.DataSize);
        except
          AppendLog('%s.TriggerClientRecvData 分配内存块失败，大小 = %d字节', [Self.ClassName, FRecvPacket.Header.DataSize], ltWarning);
          Dispose(FRecvPacket);
          Client.Disconnect;
          Exit;
        end;
      end;
      p := FRecvPacket.Data;
      Inc(p, FRecvPacketBytes - SizeOf(TIocpHeader));
      r := Min(Len, SizeOf(TIocpHeader) + FRecvPacket.Header.DataSize - FRecvPacketBytes);
      CopyMemory(p, Buf, r);
      Inc(FRecvPacketBytes, r);

      if (FRecvPacketBytes >= SizeOf(TIocpHeader) + FRecvPacket.Header.DataSize) then
      begin
        if FCrcEnabled and not CheckDataCrc(FRecvPacket^) then
        begin
          TriggerPacketDataCrcError(TIocpPacketConnection(Client), FRecvPacket^);
          FreeMem(FRecvPacket.Data);
          Dispose(FRecvPacket);
          Client.Disconnect;
          Exit;
        end;

        // 一个包正确完整接收后，触发事件
        {$ifdef __LOGIC_THREAD_POOL__}
        if (Client.AddRef = 1) then
        begin
          FreeMem(FRecvPacket.Data);
          Dispose(FRecvPacket);
          Exit;
        end;
        FJobThreadPool.AddRequest(TIocpPacketRequest.Create(TIocpPacketConnection(Client), FRecvPacket));
        FRecvPacketBytes := 0;
        FRecvPacket := nil;
        {$else}
        TriggerPacketRecv(TIocpPacketConnection(Client), FRecvPacket^);
        FRecvPacketBytes := 0;
        FreeMem(FRecvPacket.Data);
        Dispose(FRecvPacket);
        FRecvPacket := nil;
        {$endif}

        // 如果处理完一个完整的包之后还有剩余数据
        // 递归继续处理
        if (Len > r) then
        begin
          p := Buf;
          Inc(p, r);
          TriggerClientRecvData(Client, p, Len - r);
        end;
      end;
    end;
  end;
end;

procedure TIocpPacketSocket.TriggerPacketRecv(Client: TIocpPacketConnection;
  const Packet: TIocpPacket);
begin
  if Assigned(FOnPacketRecv) then
    FOnPacketRecv(Self, Client, Packet);
end;

procedure TIocpPacketSocket.TriggerPacketHeaderCrcError(Client: TIocpPacketConnection;
  const Packet: TIocpPacket);
begin
  if Assigned(FOnPacketHeaderCrcError) then
    FOnPacketHeaderCrcError(Self, Client, Packet);
end;

procedure TIocpPacketSocket.TriggerPacketDataCrcError(
  Client: TIocpPacketConnection; const Packet: TIocpPacket);
begin
  if Assigned(FOnPacketDataCrcError) then
    FOnPacketDataCrcError(Self, Client, Packet);
end;

{ TIocpPacketServer }

constructor TIocpPacketServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FListened := False;

  FAddr := '';
  FInitAcceptNum := INIT_ACCEPTEX_NUM;
  FStartTick := 0;
end;

destructor TIocpPacketServer.Destroy;
begin
  Stop;
  inherited Destroy;
end;

function TIocpPacketServer.Start: Boolean;
begin
  if FListened then Exit(True);

  StartupWorkers;
  FListened := inherited Listen(FAddr, FPort, FInitAcceptNum);
  Result := FListened;
  if Result then
    FStartTick := GetTickCount;
end;

function TIocpPacketServer.Stop: Boolean;
begin
  if not FListened then Exit(True);

  ShutdownWorkers;
  FListened := False;
  Result := True;
  FStartTick := 0;
end;

end.
