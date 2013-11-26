unit CustomDMVC.Codification;

interface

uses
  IdHashSHA,
  System.SysUtils,
  IdSSLOpenSSLHeaders;

type

  TCustomMVCCodification = class
  public
    class function EncodeBase64(pValue: string): string; static;
    class function DecodeBase64(pValue: string): string; static;
    class function HashSHA1(const pSource: string): string; static;
  end;

implementation

const
  _cBase64Code: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  _cBase64Map: array [#0 .. #127] of Integer = (
    Byte('='), 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
    64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
    64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64);

{ TCustomMVCCodification }

class function TCustomMVCCodification.DecodeBase64(pValue: string): string;
var
  i, PadCount: Integer;
  x1, x2, x3: Byte;
begin
  Result := '';

  if (length(pValue) < 4) or (length(pValue) mod 4 <> 0) then
    Exit;

  PadCount := 0;
  i := length(pValue);
  while (pValue[i] = '=')
    and (i > 0) do
  begin
    inc(PadCount);
    dec(i);
  end;

  Result := '';
  i := 1;
  while i <= length(pValue) - 3 do
  begin
    x1 := (_cBase64Map[pValue[i]] shl 2) or (_cBase64Map[pValue[i + 1]] shr 4);
    Result := Result + Char(x1);
    x2 := (_cBase64Map[pValue[i + 1]] shl 4) or (_cBase64Map[pValue[i + 2]] shr 2);
    Result := Result + Char(x2);
    x3 := (_cBase64Map[pValue[i + 2]] shl 6) or (_cBase64Map[pValue[i + 3]]);
    Result := Result + Char(x3);
    inc(i, 4);
  end;

  while PadCount > 0 do
  begin
    Delete(Result, length(Result), 1);
    dec(PadCount);
  end;
end;

class function TCustomMVCCodification.EncodeBase64(pValue: string): string;
var
  i: Integer;
  x1, x2, x3, x4: Byte;
  PadCount: Integer;
begin
  PadCount := 0;

  while length(pValue) < 3 do
  begin
    pValue := pValue + #0;
    inc(PadCount);
  end;

  while (length(pValue) mod 3) <> 0 do
  begin
    pValue := pValue + #0;
    inc(PadCount);
  end;

  Result := '';
  i := 1;

  while i <= length(pValue) - 2 do
  begin
    x1 := (Ord(pValue[i]) shr 2) and $3F;

    x2 := ((Ord(pValue[i]) shl 4) and $3F)
      or Ord(pValue[i + 1]) shr 4;

    x3 := ((Ord(pValue[i + 1]) shl 2) and $3F)
      or Ord(pValue[i + 2]) shr 6;

    x4 := Ord(pValue[i + 2]) and $3F;

    Result := Result
      + _cBase64Code[x1 + 1]
      + _cBase64Code[x2 + 1]
      + _cBase64Code[x3 + 1]
      + _cBase64Code[x4 + 1];
    inc(i, 3);
  end;

  if PadCount > 0 then
    for i := length(Result) downto 1 do
    begin
      Result[i] := '=';
      dec(PadCount);
      if PadCount = 0 then
        Break;
    end;
end;

class function TCustomMVCCodification.HashSHA1(const pSource: string): string;
var
  vSHA1: TIdHashSHA1;
begin
  Result := EmptyStr;
  if (pSource <> EmptyStr) then
    if IdSSLOpenSSLHeaders.Load() then
    begin
      vSHA1 := TIdHashSHA1.Create;
      try
        Result := LowerCase(vSHA1.HashStringAsHex(pSource));
      finally
        FreeAndNil(vSHA1);
      end;
    end;
end;

end.
