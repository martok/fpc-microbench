program ptest;

{$mode objfpc}{$H+}
{$AsmMode intel}

uses
  windows, math, ushared,
  ActiveX, comobj, Variants,
  uOpt0, uOpt1, uOpt3, uOpt4;

// how many PC events per cycle?
function CalibrateClock(pf: Int64): Int64;
var
  pc1,pc2: Int64;
begin
  Write('    ','perfcounter-cal':20,' : ');
  QueryPerformanceCounter(pc1{%H-});
  { a NOP is between 0.2 and 0.33 cycles on modern architectures
     AMD K10: 0.33
     AMD Bulldozer, Piledriver, Steamroller: 0.25
     AMD Ryzen: 0.2
     Intel Nehalem: 0.33
     Intel Sandy Bridge, Ivy Bridge, Haswell, Broadwell, Skylake: 0.25

     => 4 nops is going to be one clock on most. Burn CAL_CYCLES_IN_BLOCK at once to keep interference from loop low.
  }
  asm
    mov eax, CAL_NUM_CYCLES/CAL_CYCLES_IN_BLOCK
  @@1:
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

    dec eax
    jnz @@1
  end;
  QueryPerformanceCounter(pc2{%H-});
  Result:= (CAL_NUM_CYCLES) div (pc2-pc1);
  WriteLn(Result:13,' cycles per PC = ',1/Result:15:6,' PC per cycle =   core clock ',Result*pf/1e9:6:3,' GHz');
end;

var
  pf_ct,                     // QPC: counts per second
  pf_cy: Int64;              // CalibrateClock: cycles per count

procedure Statistics(const data: array of Int64; out mean, stddev, tmin, tmax: Double);
var
  de: array of Extended;
  i: Integer;
  d: Int64;
  m, s: float;
begin
  m:= 0;
  s:= 0;
  tmin:= high(Int64);
  tmax:= Low(Int64);
  SetLength(de, Length(data));
  for i:= 0 to high(de) do begin
    d:= data[i];
    de[i]:= d;
    if d > tmax then tmax:= d;
    if d < tmin then tmin:= d;
  end;
  meanandstddev(de, m, s);
  mean:= m;
  stddev:= s;
end;

procedure DoTest(m: TProcedure; Name: string);
var
  pc1,pc2: Int64;
  Times: array[0..TEST_REPEAT-1] of Int64;
  i: Integer;
  mean, stddev, tmin, tmax: Double;
begin
  Write('[*] ',Name:20,' :');
  for i:= 0 to TEST_REPEAT-1 do begin
    QueryPerformanceCounter(pc1{%H-});
    m();
    QueryPerformanceCounter(pc2{%H-});
    Times[i]:= pc2-pc1;
  end;
  Statistics(Times, mean, stddev, tmin, tmax);
  WriteLn(' ', mean/pf_ct*1e6:15:6,' us',
          ' ', mean*pf_cy:15:1,' cycles',
          ' ', mean*pf_cy/RANDOM_ARRAY_LEN:13:3,
          ' ', '+/- ',stddev*pf_cy/RANDOM_ARRAY_LEN:5:3,' cycles/inner',
          ' ', '[',
          ' ', 100*stddev/mean:6:1,' %CV',
          ' ', 100*(tmax-tmin)/mean:6:1,' %R',
          ' ', ']');
end;

procedure Recalibrate;
var
  pfo: int64;
  i: Integer;
begin
  pfo:= pf_cy;
  for i:= 1 to 10 do begin
    pf_cy:= CalibrateClock(pf_ct);
    if abs(pfo-pf_cy) < CAL_TARGET * pf_cy then
      break;
    pfo:= pf_cy;
  end;
end;

function VariantToStr(const aVariant: Variant): String;
begin
  result := '';
  if (TVarData(aVariant).vtype <> varempty) and
     (TVarData(aVariant).vtype <> varnull) and
     (TVarData(aVariant).vtype <> varerror) then begin
    result := aVariant;
  end;
end;

procedure PrintCPUInfo;
const
  WBEM_FLAGFORWARDONLY = $00000020;
var
  SWbemLocator, WMIService: OLEVariant;
  WbemObjectSet, WbemObject, oProp: OLEVariant;
  pCeltFetched: LongWord;
  oEnum: IEnumvariant;
  i: Integer;
begin
  CoInitialize(nil);
  SWbemLocator:= CreateOleObject('WbemScripting.SWbemLocator');
  WMIService:= SWbemLocator.ConnectServer('localhost','root\CIMV2', '', '');
  WbemObjectSet:= WMIService.ExecQuery('SELECT * FROM WIN32_Processor', 'WQL', WBEM_FLAGFORWARDONLY);
  oEnum:= IUnknown(WbemObjectSet._NewEnum) as IEnumVariant;
  i:= 0;
  while oEnum.Next(1, WbemObject, pCeltFetched) = 0 do begin
    Write('CPU ',i:3,' :');
    oProp:= WbemObject.Properties_;

    Write(' ', VariantToStr(oProp.Item('Manufacturer').Value));
    Write(' ', VariantToStr(oProp.Item('Name').Value));
    Write(' ', VariantToStr(oProp.Item('Caption').Value));
    WriteLn('');
    inc(i);
  end;
end;

begin
  Randomize;
  SetConsoleCP(CP_ACP);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  SetThreadAffinityMask(GetCurrentThread, 1);
  Writeln('Platform: ','FPC',{$I %FPCVersion%},' ',{$I %FPCTargetCPU%}, '-',{$I %FPCTargetOS%});
  WriteLn('Build   : ',{$I %Date%},' ', {$I %Time%});
  PrintCPUInfo;

  QueryPerformanceFrequency(pf_ct{%H-});
  pf_cy:= CalibrateClock(pf_ct);
  Recalibrate;

  WriteLn('Array : ',RANDOM_ARRAY_LEN,'*',Low(ARRAY_BASE_TYPE),'..',High(ARRAY_BASE_TYPE));
  WriteLn('Repeat: ',TEST_REPEAT,' times');

  //DoTest(@uOpt3.CaseAsm,  'O3 case-asm');
  //DoTest(@uOpt3.CaseAsm2, 'O3 case-asm2');
  //DoTest(@uOpt3.ArrayNop, 'O3 array-nop');
  //DoTest(@uOpt0.ArrayQPC, 'O0 array-qpc');
  //DoTest(@uOpt3.ArrayQPC, 'O3 array-qpc');

  {DoTest(@uOpt0.CompareByte1,  'O0 compare-byte-1');
  DoTest(@uOpt1.CompareByte1,  'O1 compare-byte-1');
  DoTest(@uOpt3.CompareByte1,  'O3 compare-byte-1');
  DoTest(@uOpt0.CompareByte2,  'O0 compare-byte-2');
  DoTest(@uOpt1.CompareByte2,  'O1 compare-byte-2');
  DoTest(@uOpt3.CompareByte2,  'O3 compare-byte-2');

  DoTest(@uOpt0.RandomArray, 'O0 random-array');
  DoTest(@uOpt0.Case5,       'O0 case-of-5');
  DoTest(@uOpt0.Case5Else,   'O0 case-of-5-else');
  DoTest(@uOpt0.Case20,      'O0 case-of-20');
  DoTest(@uOpt0.Case20Else,  'O0 case-of-20-else');
  Recalibrate;

  DoTest(@uOpt1.RandomArray, 'O1 random-array');
  DoTest(@uOpt1.Case5,       'O1 case-of-5');
  DoTest(@uOpt1.Case5Else,   'O1 case-of-5-else');
  DoTest(@uOpt1.Case20,      'O1 case-of-20');
  DoTest(@uOpt1.Case20Else,  'O1 case-of-20-else');
  Recalibrate;
  DoTest(@uOpt3.RandomArray, 'O3 random-array');
  DoTest(@uOpt3.Case5,       'O3 case-of-5');
  DoTest(@uOpt3.Case5Else,   'O3 case-of-5-else');  }
  DoTest(@uOpt3.Case20,      'O3 case-of-20');
  DoTest(@uOpt3.Case20Else,  'O3 case-of-20-else');

  Recalibrate;
  DoTest(@uOpt4.RandomArray, 'O4 random-array');
  DoTest(@uOpt4.Case5,       'O4 case-of-5');
  DoTest(@uOpt4.Case5Else,   'O4 case-of-5-else');
  DoTest(@uOpt4.Case20,      'O4 case-of-20');
  DoTest(@uOpt4.Case20Else,  'O4 case-of-20-else');

  WriteLn('Done.');
  REadln;
end.

