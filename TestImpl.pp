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
procedure CaseAsm2;

procedure CompareByte1;
procedure CompareByte2;

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
    mov v, EAX
    jmp @@t2
@@t2:
    //nop;nop;nop;nop; nop;nop;nop;nop; nop;nop;nop;nop;
    jmp @@t1
@@t1:
    nop;
  end;
end;

procedure CaseAsm2;
var
  v, i: Integer;
begin
 { for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));  }
  v:= 0;
  for i:= low(x) to high(x) do
    asm
    mov EAX, i
    movZX EAX, byte x[EAX]
    cmp EAX, 19
    ja @@t1
    mov v, EAX
@@t2:
    //nop;nop;nop;nop; nop;nop;nop;nop; nop;nop;nop;nop;
    jmp @@t1
@@t1:
    nop;
  end;
end;

{$IFDEF CPU64}
{$AsmMode att}
function CompareBytePatch(Const buf1,buf2;len:SizeInt):SizeInt; assembler; nostackframe;
{ win64: rcx buf, rdx buf, r8 len
  linux: rdi buf, rsi buf, rdx len }
asm
{$ifndef win64}
    mov    %rdx, %r8
    mov    %rsi, %rdx
    mov    %rdi, %rcx
{$endif win64}
    negq    %r8
    jz      .LCmpbyteZero

    subq    %r8, %rcx
    subq    %r8, %rdx


    .balign 8
.LCmpbyteLoop:
{$ifdef oldbinutils}
// for the reason why this alternate coding of movzbl is given here
// see the comments in FillChar above
    .byte 0x42,0x0F,0xB6,0x04,0x01
{$else}
    movzbl  (%rcx,%r8), %eax
{$endif}
    cmpb    (%rdx,%r8), %al
    jne     .LCmpbyteExitFast
    addq    $1, %r8
    jne     .LCmpbyteLoop
.LCmpbyteZero:
     xorl    %eax, %eax
     retq

.LCmpbyteExitFast:

{$ifdef oldbinutils}
    .byte 0x42,0x0F,0xB6,0x0C,0x02
{$else}
     movzbl  (%rdx,%r8), %ecx    { Compare last position }
{$endif}
     subq    %rcx, %rax
end;
{$ENDIF}

procedure CompareByte1;
var
  buf1,buf2 : array[0..127] of byte;
  v, i, len, j: Integer;
begin
 { for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));  }
  v:= 0;
  for i:= low(x) to high(x) do begin
    len:=random(100);
    for j:=0 to len-1 do
      begin
        buf1[j]:=random(256);
        buf2[j]:=random(256);
      end;

    for j:=0 to random(10) do
      buf2[j]:=buf1[j];

    for j:=1 to 10000 do
      System.CompareByte(buf1,buf2,len);
  end;
end;

procedure CompareByte2;
var
  buf1,buf2 : array[0..127] of byte;
  v, i, len, j: Integer;
begin
  {$IFDEF CPU64}
 { for i:= low(x) to high(x) do
    x[i]:= Random(high(ARRAY_BASE_TYPE));  }
  v:= 0;
  for i:= low(x) to high(x) do begin
    len:=random(100);
    for j:=0 to len-1 do
      begin
        buf1[j]:=random(256);
        buf2[j]:=random(256);
      end;

    for j:=0 to random(10) do
      buf2[j]:=buf1[j];

    for j:=1 to 10000 do
      CompareBytePatch(buf1,buf2,len);
  end;
  {$ENDIF}
end;
{$ENDIF}
