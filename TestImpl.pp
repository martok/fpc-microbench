{$IFDEF INC_HEAD}

uses
  ushared, windows;

{$AsmMode intel}

procedure RandomArray;
procedure ArrayNop;
procedure ArrayQPC;
procedure RandomArrayNop;
procedure Case5;
procedure Case5Else;
procedure Case20;
procedure Case20Else;
procedure CaseAsm;

{$ELSE}

var
  x: array[0..RANDOM_ARRAY_LEN-1] of ARRAY_BASE_TYPE;

procedure RandomArray;
var
  i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
end;

procedure ArrayNop;
var
  i: Integer;
  p: int64;
begin
  for i:= low(x) to high(x) do
    asm nop;nop;nop;nop end;
end;

procedure ArrayQPC;
var
  i: Integer;
  p: int64;
begin
  for i:= low(x) to high(x) do
    QueryPerformanceCounter(p);
end;

procedure RandomArrayNop;
var
  i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
  for i:= low(x) to high(x) do begin
    asm
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;

      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;

      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;

      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
      nop ; nop; nop; nop;
    end;
  end;
end;

procedure Case5;
var
  v, i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
  v:= 0;
  for i:= low(x) to high(x) do begin
    case x[i] of
      0: v:= 0;
      1: v:= 1;
      2: v:= 2;
      3: v:= 3;
      4: v:= 4;
      5: v:= 5;
    end;
  end;
end;

procedure Case5Else;
var
  v, i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
  v:= 0;
  for i:= low(x) to high(x) do begin
    case x[i] of
      0: v:= 0;
      1: v:= 1;
      2: v:= 2;
      3: v:= 3;
      4: v:= 4;
      5: v:= 5;
    else
      v:= 99;
    end;
  end;
end;

procedure Case20;
var
  v, i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
  v:= 0;
  for i:= low(x) to high(x) do begin
    case x[i] of
      0: v:= 0;
      1: v:= 1;
      2: v:= 2;
      3: v:= 3;
      4: v:= 4;
      5: v:= 5;
      6: v:= 6;
      7: v:= 7;
      8: v:= 8;
      9: v:= 9;
      10: v:= 10;
      11: v:= 11;
      12: v:= 12;
      13: v:= 13;
      14: v:= 14;
      15: v:= 15;
      16: v:= 16;
      17: v:= 17;
      18: v:= 18;
      19: v:= 19;
    end;
  end;
end;

procedure Case20Else;
var
  v, i: Integer;
begin
  for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));
  v:= 0;
  for i:= low(x) to high(x) do begin
    case x[i] of
      0: v:= 0;
      1: v:= 1;
      2: v:= 2;
      3: v:= 3;
      4: v:= 4;
      5: v:= 5;
      6: v:= 6;
      7: v:= 7;
      8: v:= 8;
      9: v:= 9;
      10: v:= 10;
      11: v:= 11;
      12: v:= 12;
      13: v:= 13;
      14: v:= 14;
      15: v:= 15;
      16: v:= 16;
      17: v:= 17;
      18: v:= 18;
      19: v:= 19;
    else
      v:= 99;
    end;
  end;
end;

procedure CaseAsm;
var
  v, i: Integer;
begin
 { for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));  }
  v:= 0;
  for i:= low(x) to high(x) do
    asm
    mov EAX, i
    mov AL, byte x[EAX]
    cmp AL, 19
    ja @@t1
    and EAX, $ff
    mov v, EAX
    jmp @@t2
@@t2:
    //nop;nop;nop;nop; nop;nop;nop;nop; nop;nop;nop;nop;
    jmp @@t1
@@t1:
    nop;
  end;
end;

{$ENDIF}
