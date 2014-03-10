unit Iocp.TimerQueue;

{基于Win32系统的时钟队列
主要用于检测IOCP连接是否超时
}

interface

uses
  Windows, Classes, SysUtils, SyncObjs, System.Generics.Collections, Iocp.Logger;

type
  TIocpTimerQueueTimer = class;
  TIocpTimerQueueTimerList = TList<TIocpTimerQueueTimer>;
  TIocpTimerQueue = class
  private
    FRefCount: Integer;
    FTimerQueueHandle: THandle;
    FTimerList: TIocpTimerQueueTimerList;
    FLocker: TCriticalSection;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddRef: Integer;
    function Release: Boolean;

    property Handle: THandle read FTimerQueueHandle;
    property RefCount: Integer read FRefCount;
  end;

  TIocpTimerQueueTimer = class
  private
    FTimerQueue: TIocpTimerQueue;
    FTimerHandle: THandle;
    FInterval: DWORD;
    FRefCount: Integer;
    FOnTimer: TNotifyEvent;
    FOnDestroy: TNotifyEvent;

    procedure SetInterval(const Value: DWORD);
  protected
    procedure Execute; virtual;
  public
    constructor Create(TimerQueue: TIocpTimerQueue; Interval: DWORD; OnCreate: TNotifyEvent); virtual;
    destructor Destroy; override;

    function AddRef: Integer;
    function Release: Boolean;

    property Interval: DWORD read FInterval write SetInterval;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

implementation

procedure WaitOrTimerCallback(Timer: TIocpTimerQueueTimer; TimerOrWaitFired: ByteBool); stdcall;
begin
  try
    Timer.Execute;
  except
  end;
end;

{ TIocpTimerQueue }

constructor TIocpTimerQueue.Create;
begin
  FTimerQueueHandle := CreateTimerQueue();
  FTimerList := TIocpTimerQueueTimerList.Create;
  FLocker := TCriticalSection.Create;
  FRefCount := 1;
end;

destructor TIocpTimerQueue.Destroy;
var
  Timer: TIocpTimerQueueTimer;
  i: Integer;
begin
  DeleteTimerQueueEx(FTimerQueueHandle, 0);
  FTimerQueueHandle := INVALID_HANDLE_VALUE;

  try
    FLocker.Enter;
    // thanks Hezihang2012
    i := 0;
    while (i < FTimerList.Count) do
    begin
      Timer := FTimerList[i];
      Timer.Release;
      if (Timer = FTimerList[i]) then Inc(i);
    end;
  finally
    FLocker.Leave;
  end;

  FTimerList.Free;
  FLocker.Free;

  inherited Destroy;
end;

function TIocpTimerQueue.AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TIocpTimerQueue.Release: Boolean;
begin
  Result := (InterlockedDecrement(FRefCount) = 0);
  if not Result then Exit;

  Free;
end;

{ TIocpTimerQueueTimer }

constructor TIocpTimerQueueTimer.Create(TimerQueue: TIocpTimerQueue; Interval: DWORD; OnCreate: TNotifyEvent);
begin
  FTimerQueue := TimerQueue;
  FInterval := Interval;
  FRefCount := 1;

  // 参数DueTime设置为100，表示100毫秒后才启动Timer
  // 这样做是为了让Timer等待对象创建完成，否则可能会出现Timer中访问对象，但是对象尚未创建成功
  if not CreateTimerQueueTimer(FTimerHandle, FTimerQueue.Handle, @WaitOrTimerCallback, Pointer(Self), 100, FInterval, 0) then
  begin
    raise Exception.Create('CreateTimerQueueTimer failed');
  end;

  try
    FTimerQueue.AddRef;
    FTimerQueue.FLocker.Enter;
    FTimerQueue.FTimerList.Add(Self);
  finally
    FTimerQueue.FLocker.Leave;
  end;

  if Assigned(OnCreate) then
    OnCreate(Self);
end;

destructor TIocpTimerQueueTimer.Destroy;
begin
  if Assigned(FOnDestroy) then
    FOnDestroy(Self);

  if (FTimerQueue.Handle <> INVALID_HANDLE_VALUE) then
    DeleteTimerQueueTimer(FTimerQueue.Handle, FTimerHandle, 0);

  try
    FTimerQueue.FLocker.Enter;
    FTimerQueue.FTimerList.Remove(Self);
  finally
    FTimerQueue.FLocker.Leave;
    FTimerQueue.Release;
  end;

  inherited Destroy;
end;

function TIocpTimerQueueTimer.AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TIocpTimerQueueTimer.Release: Boolean;
begin
  Result := (InterlockedDecrement(FRefCount) = 0);
  if not Result then Exit;

  Free;
end;

procedure TIocpTimerQueueTimer.Execute;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

procedure TIocpTimerQueueTimer.SetInterval(const Value: DWORD);
begin
  FInterval := Value;
  ChangeTimerQueueTimer(FTimerQueue.Handle, FTimerHandle, 0, FInterval)
end;

end.
